# GitLab Runner Module
#
# Deploys GitLab Runner to Kubernetes using Helm with optional
# headless registration via GitLab API.
#
# Features:
#   - Helm-based deployment
#   - API-based runner registration (optional)
#   - Configurable executor settings
#   - RBAC configuration
#   - Resource limits

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# =============================================================================
# Runner Registration via GitLab API
# =============================================================================

# Register runner via GitLab API (headless registration)
resource "null_resource" "register_runner" {
  count = var.gitlab_api_token != "" && var.project_id != "" ? 1 : 0

  triggers = {
    runner_name      = var.runner_name
    tags             = join(",", var.runner_tags)
    project_id       = var.project_id
    gitlab_url       = var.gitlab_url
    gitlab_api_token = var.gitlab_api_token
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      # Register runner via GitLab API
      RESPONSE=$(curl --fail --silent --request POST \
        --url "${self.triggers.gitlab_url}/api/v4/user/runners" \
        --header "PRIVATE-TOKEN: ${self.triggers.gitlab_api_token}" \
        --form "runner_type=project_type" \
        --form "project_id=${self.triggers.project_id}" \
        --form "description=${self.triggers.runner_name}" \
        --form "tag_list=${self.triggers.tags}" \
        --form "run_untagged=${var.run_untagged}" \
        --form "locked=${var.locked}")

      echo "$RESPONSE" > /tmp/runner_registration_${self.triggers.runner_name}.json

      # Extract token
      TOKEN=$(echo "$RESPONSE" | jq -r '.token // empty')
      if [ -z "$TOKEN" ]; then
        echo "Error: Failed to register runner or extract token"
        echo "Response: $RESPONSE"
        exit 1
      fi

      echo "$TOKEN" > /tmp/runner_token_${self.triggers.runner_name}.txt
      echo "Runner registered successfully: ${self.triggers.runner_name}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      set +e

      RUNNER_ID=$(cat /tmp/runner_registration_${self.triggers.runner_name}.json 2>/dev/null | jq -r '.id // empty')

      if [ -n "$RUNNER_ID" ] && [ "$RUNNER_ID" != "null" ]; then
        echo "Deleting runner $RUNNER_ID..."
        curl --silent --request DELETE \
          --url "${self.triggers.gitlab_url}/api/v4/runners/$RUNNER_ID" \
          --header "PRIVATE-TOKEN: ${self.triggers.gitlab_api_token}" || true
      fi

      # Clean up temp files
      rm -f /tmp/runner_registration_${self.triggers.runner_name}.json
      rm -f /tmp/runner_token_${self.triggers.runner_name}.txt

      echo "Runner cleanup complete"
    EOT
  }
}

# Read registered token
data "local_file" "runner_token" {
  count      = var.gitlab_api_token != "" && var.project_id != "" ? 1 : 0
  filename   = "/tmp/runner_token_${var.runner_name}.txt"
  depends_on = [null_resource.register_runner]
}

# =============================================================================
# Kubernetes Namespace
# =============================================================================

resource "kubernetes_namespace_v1" "runner" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "gitlab-runner"
      "app.kubernetes.io/component"  = var.runner_name
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }
}

# =============================================================================
# GitLab Runner Helm Release
# =============================================================================

locals {
  # Determine runner token: API-registered or pre-existing
  runner_token = var.gitlab_api_token != "" && var.project_id != "" ? (
    trimspace(data.local_file.runner_token[0].content)
  ) : var.runner_token

  # Generate complete helm values
  helm_values = yamlencode({
    gitlabUrl   = var.gitlab_url
    runnerToken = local.runner_token
    concurrent  = var.concurrent_jobs
    checkInterval = var.poll_interval

    rbac = {
      create            = var.rbac_create
      clusterWideAccess = var.cluster_wide_access
    }

    serviceAccount = {
      create = var.service_account_create
      name   = var.service_account_name != "" ? var.service_account_name : var.runner_name
    }

    resources = {
      requests = {
        cpu    = var.cpu_request
        memory = var.memory_request
      }
      limits = {
        cpu    = var.cpu_limit
        memory = var.memory_limit
      }
    }

    runners = {
      privileged = var.privileged
      namespace  = var.namespace

      config = <<-TOML
        [[runners]]
          name = "${var.runner_name}"
          executor = "kubernetes"
          [runners.kubernetes]
            namespace = "${var.namespace}"
            image = "${var.default_image}"
            image_pull_policy = "${var.image_pull_policy}"
            privileged = ${var.privileged}
            cpu_request = "${var.helper_cpu_request}"
            memory_request = "${var.helper_memory_request}"
            service_cpu_request = "${var.service_cpu_request}"
            service_memory_request = "${var.service_memory_request}"
            [runners.kubernetes.pod_labels]
              "app.kubernetes.io/managed-by" = "gitlab-runner"
              "app.kubernetes.io/name" = "gitlab-runner-job"
      TOML
    }

    podSecurityContext = {
      runAsNonRoot = true
      runAsUser    = 1000
      fsGroup      = 1000
    }

    securityContext = {
      allowPrivilegeEscalation = false
      readOnlyRootFilesystem   = false
      capabilities = {
        drop = ["ALL"]
      }
    }
  })
}

resource "helm_release" "gitlab_runner" {
  name             = var.runner_name
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false

  depends_on = [
    kubernetes_namespace_v1.runner,
    null_resource.register_runner
  ]

  # Use generated values or custom additional_values
  values = var.additional_values != "" ? [var.additional_values] : [local.helm_values]
}
