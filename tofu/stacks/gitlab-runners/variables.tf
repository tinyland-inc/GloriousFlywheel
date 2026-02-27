# GitLab Runners Stack - Variables

# =============================================================================
# Kubernetes Authentication
# =============================================================================

variable "k8s_config_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = ""
}

variable "cluster_context" {
  description = "Kubernetes context for GitLab Agent"
  type        = string
}

# =============================================================================
# GitLab Configuration
# =============================================================================

variable "gitlab_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "https://gitlab.com"
}

# =============================================================================
# Namespace
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for runners"
  type        = string
  default     = "gitlab-runners"
}

variable "create_namespace" {
  description = "Create the namespace"
  type        = bool
  default     = true
}

# =============================================================================
# Runner Tokens (sensitive - pass via -var flags)
# =============================================================================

variable "nix_runner_token" {
  description = "Runner token for Nix runner (create in GitLab > Settings > CI/CD > Runners)"
  type        = string
  sensitive   = true
}

variable "docker_runner_token" {
  description = "Runner token for Docker runner"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dind_runner_token" {
  description = "Runner token for DinD runner"
  type        = string
  sensitive   = true
  default     = ""
}

# =============================================================================
# Runner Names (override per deployment)
# =============================================================================

variable "nix_runner_name" {
  description = "Helm release name for Nix runner"
  type        = string
  default     = "nix-runner"
}

variable "docker_runner_name" {
  description = "Helm release name for Docker runner"
  type        = string
  default     = "docker-runner"
}

variable "dind_runner_name" {
  description = "Helm release name for DinD runner"
  type        = string
  default     = "dind-runner"
}

# =============================================================================
# Deploy Toggles
# =============================================================================

variable "deploy_docker_runner" {
  description = "Deploy the Docker runner"
  type        = bool
  default     = true
}

variable "deploy_dind_runner" {
  description = "Deploy the DinD runner"
  type        = bool
  default     = false
}

# =============================================================================
# Common Runner Configuration
# =============================================================================

variable "use_legacy_exec_strategy" {
  description = "Use legacy Kubernetes exec strategy"
  type        = bool
  default     = true
}

variable "spread_to_nodes" {
  description = "Enable pod anti-affinity to spread across nodes"
  type        = bool
  default     = true
}

variable "manager_priority_class_name" {
  description = "PriorityClass for runner manager pods"
  type        = string
  default     = ""
}

variable "job_priority_class_name" {
  description = "PriorityClass for CI job pods"
  type        = string
  default     = ""
}

# =============================================================================
# Manager Pod Resources (shared across all runners)
# =============================================================================

variable "manager_cpu_request" {
  description = "CPU request for runner manager pods"
  type        = string
  default     = "50m"
}

variable "manager_memory_request" {
  description = "Memory request for runner manager pods"
  type        = string
  default     = "128Mi"
}

variable "manager_cpu_limit" {
  description = "CPU limit for runner manager pods"
  type        = string
  default     = "200m"
}

variable "manager_memory_limit" {
  description = "Memory limit for runner manager pods"
  type        = string
  default     = "256Mi"
}

# =============================================================================
# Nix Runner Configuration
# =============================================================================

variable "nix_concurrent_jobs" {
  description = "Max concurrent Nix build jobs"
  type        = number
  default     = 6
}

variable "nix_job_cpu_request" {
  type    = string
  default = "500m"
}

variable "nix_job_memory_request" {
  type    = string
  default = "1Gi"
}

variable "nix_job_cpu_limit" {
  type    = string
  default = "4"
}

variable "nix_job_memory_limit" {
  type    = string
  default = "8Gi"
}

variable "nix_hpa_enabled" {
  type    = bool
  default = true
}

variable "nix_hpa_min_replicas" {
  type    = number
  default = 2
}

variable "nix_hpa_max_replicas" {
  type    = number
  default = 5
}

variable "attic_server" {
  description = "Attic cache server URL for Nix runner"
  type        = string
  default     = ""
}

variable "attic_cache" {
  description = "Attic cache name"
  type        = string
  default     = "main"
}

# =============================================================================
# Docker Runner Configuration
# =============================================================================

variable "docker_concurrent_jobs" {
  description = "Max concurrent Docker jobs"
  type        = number
  default     = 12
}

variable "docker_job_cpu_request" {
  type    = string
  default = "100m"
}

variable "docker_job_memory_request" {
  type    = string
  default = "256Mi"
}

variable "docker_job_cpu_limit" {
  type    = string
  default = "2"
}

variable "docker_job_memory_limit" {
  type    = string
  default = "4Gi"
}

variable "docker_hpa_enabled" {
  type    = bool
  default = true
}

variable "docker_hpa_min_replicas" {
  type    = number
  default = 2
}

variable "docker_hpa_max_replicas" {
  type    = number
  default = 8
}

# =============================================================================
# DinD Runner Configuration
# =============================================================================

variable "dind_concurrent_jobs" {
  description = "Max concurrent DinD jobs"
  type        = number
  default     = 6
}

variable "dind_job_cpu_request" {
  type    = string
  default = "500m"
}

variable "dind_job_memory_request" {
  type    = string
  default = "1Gi"
}

variable "dind_job_cpu_limit" {
  type    = string
  default = "4"
}

variable "dind_job_memory_limit" {
  type    = string
  default = "8Gi"
}

variable "dind_hpa_enabled" {
  type    = bool
  default = true
}

variable "dind_hpa_min_replicas" {
  type    = number
  default = 1
}

variable "dind_hpa_max_replicas" {
  type    = number
  default = 5
}

# =============================================================================
# Runner Cleanup
# =============================================================================

variable "enable_runner_cleanup" {
  description = "Deploy runner cleanup CronJob"
  type        = bool
  default     = false
}

variable "kubectl_image" {
  description = "Container image for kubectl (cleanup job)"
  type        = string
  default     = "bitnami/kubectl:latest"
}

# =============================================================================
# GHCR Registry Authentication
# =============================================================================

variable "ghcr_token" {
  description = "GHCR personal access token for pulling mirrored images (empty to skip)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ghcr_username" {
  description = "GHCR username for image pull authentication"
  type        = string
  default     = ""
}
