# ARC Controller Module
#
# Deploys GitHub Actions Runner Controller (ARC) to Kubernetes via Helm chart.
# The controller manages runner scale sets for GitHub Actions workflows.

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# =============================================================================
# Kubernetes Namespace
# =============================================================================

resource "kubernetes_namespace_v1" "arc_systems" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

# =============================================================================
# ARC Controller Helm Release
# =============================================================================

resource "helm_release" "arc_controller" {
  name       = var.release_name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 600

  depends_on = [kubernetes_namespace_v1.arc_systems]

  # Controller resources
  set {
    name  = "resources.requests.cpu"
    value = var.cpu_request
  }

  set {
    name  = "resources.requests.memory"
    value = var.memory_request
  }

  set {
    name  = "resources.limits.cpu"
    value = var.cpu_limit
  }

  set {
    name  = "resources.limits.memory"
    value = var.memory_limit
  }

  # Update strategy (eventual = lower API load)
  set {
    name  = "flags.updateStrategy"
    value = var.update_strategy
  }

  # Log level
  set {
    name  = "flags.logLevel"
    value = var.log_level
  }

  # Image pull secrets
  dynamic "set" {
    for_each = var.image_pull_secrets
    content {
      name  = "imagePullSecrets[${set.key}].name"
      value = set.value
    }
  }
}
