# GitLab Runners Stack
#
# Deploys self-hosted GitLab Runners to Kubernetes via Helm chart.
# Supports 3 runner types: nix (Nix builds), docker (general CI), dind (Docker-in-Docker).

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "kubernetes" {
  config_path    = var.k8s_config_path != "" ? var.k8s_config_path : null
  config_context = var.cluster_context
}

provider "helm" {
  kubernetes {
    config_path    = var.k8s_config_path != "" ? var.k8s_config_path : null
    config_context = var.cluster_context
  }
}

# =============================================================================
# Nix Runner - For Nix build jobs
# =============================================================================

module "nix_runner" {
  source = "../../modules/gitlab-runner"

  runner_name      = var.nix_runner_name
  runner_type      = "nix"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  gitlab_url   = var.gitlab_url
  runner_token = var.nix_runner_token

  concurrent_jobs          = var.nix_concurrent_jobs
  use_legacy_exec_strategy = var.use_legacy_exec_strategy
  spread_to_nodes          = var.spread_to_nodes

  # Manager pod resources
  cpu_request    = var.manager_cpu_request
  memory_request = var.manager_memory_request
  cpu_limit      = var.manager_cpu_limit
  memory_limit   = var.manager_memory_limit

  manager_priority_class_name = var.manager_priority_class_name
  job_priority_class_name     = var.job_priority_class_name

  # Job pod resources
  job_cpu_request    = var.nix_job_cpu_request
  job_memory_request = var.nix_job_memory_request
  job_cpu_limit      = var.nix_job_cpu_limit
  job_memory_limit   = var.nix_job_memory_limit

  # HPA
  hpa_enabled      = var.nix_hpa_enabled
  hpa_min_replicas = var.nix_hpa_min_replicas
  hpa_max_replicas = var.nix_hpa_max_replicas

  # Nix/Attic configuration
  attic_server = var.attic_server
  attic_cache  = var.attic_cache
}

# =============================================================================
# Docker Runner - For general CI jobs
# =============================================================================

module "docker_runner" {
  source = "../../modules/gitlab-runner"
  count  = var.deploy_docker_runner ? 1 : 0

  runner_name      = var.docker_runner_name
  runner_type      = "docker"
  namespace        = var.namespace
  create_namespace = false

  depends_on = [module.nix_runner]

  gitlab_url   = var.gitlab_url
  runner_token = var.docker_runner_token

  concurrent_jobs          = var.docker_concurrent_jobs
  use_legacy_exec_strategy = var.use_legacy_exec_strategy
  spread_to_nodes          = var.spread_to_nodes

  # Manager pod resources
  cpu_request    = var.manager_cpu_request
  memory_request = var.manager_memory_request
  cpu_limit      = var.manager_cpu_limit
  memory_limit   = var.manager_memory_limit

  manager_priority_class_name = var.manager_priority_class_name
  job_priority_class_name     = var.job_priority_class_name

  # Job pod resources
  job_cpu_request    = var.docker_job_cpu_request
  job_memory_request = var.docker_job_memory_request
  job_cpu_limit      = var.docker_job_cpu_limit
  job_memory_limit   = var.docker_job_memory_limit

  # HPA
  hpa_enabled      = var.docker_hpa_enabled
  hpa_min_replicas = var.docker_hpa_min_replicas
  hpa_max_replicas = var.docker_hpa_max_replicas
}

# =============================================================================
# DinD Runner - For Docker-in-Docker jobs
# =============================================================================

module "dind_runner" {
  source = "../../modules/gitlab-runner"
  count  = var.deploy_dind_runner ? 1 : 0

  runner_name      = var.dind_runner_name
  runner_type      = "dind"
  namespace        = var.namespace
  create_namespace = false

  depends_on = [module.nix_runner]

  gitlab_url   = var.gitlab_url
  runner_token = var.dind_runner_token

  concurrent_jobs          = var.dind_concurrent_jobs
  use_legacy_exec_strategy = var.use_legacy_exec_strategy
  spread_to_nodes          = var.spread_to_nodes

  # Manager pod resources
  cpu_request    = var.manager_cpu_request
  memory_request = var.manager_memory_request
  cpu_limit      = var.manager_cpu_limit
  memory_limit   = var.manager_memory_limit

  manager_priority_class_name = var.manager_priority_class_name
  job_priority_class_name     = var.job_priority_class_name

  # Job pod resources
  job_cpu_request    = var.dind_job_cpu_request
  job_memory_request = var.dind_job_memory_request
  job_cpu_limit      = var.dind_job_cpu_limit
  job_memory_limit   = var.dind_job_memory_limit

  # HPA
  hpa_enabled      = var.dind_hpa_enabled
  hpa_min_replicas = var.dind_hpa_min_replicas
  hpa_max_replicas = var.dind_hpa_max_replicas
}

# =============================================================================
# GHCR Registry Auth (imagePullSecret)
# =============================================================================

resource "kubernetes_secret" "ghcr_auth" {
  count = var.ghcr_token != "" ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.ghcr_username != ""
      error_message = "ghcr_username is required when ghcr_token is set"
    }
  }

  metadata {
    name      = "ghcr-auth"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "ghcr-auth"
      "app.kubernetes.io/component"  = "registry-credentials"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.ghcr_username}:${var.ghcr_token}")
        }
      }
    })
  }

  depends_on = [module.nix_runner]
}

locals {
  ghcr_pull_secrets = var.ghcr_token != "" ? ["ghcr-auth"] : []
}

# =============================================================================
# Runner Cleanup CronJob
# =============================================================================

module "runner_cleanup" {
  count  = var.enable_runner_cleanup ? 1 : 0
  source = "../../modules/runner-cleanup"

  namespace          = var.namespace
  kubectl_image      = var.kubectl_image
  image_pull_secrets = local.ghcr_pull_secrets

  depends_on = [module.nix_runner]
}
