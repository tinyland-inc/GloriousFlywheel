# GitLab Runner Module - Variables

# =============================================================================
# GitLab Configuration
# =============================================================================

variable "gitlab_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_api_token" {
  description = "GitLab API token with runner registration permissions (create_runner scope)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "project_id" {
  description = "GitLab project ID for runner registration"
  type        = string
  default     = ""
}

variable "runner_token" {
  description = "Pre-existing runner authentication token (used when gitlab_api_token is not provided)"
  type        = string
  sensitive   = true
  default     = ""
}

# =============================================================================
# Runner Configuration
# =============================================================================

variable "runner_name" {
  description = "Name for the runner (used as Helm release name)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.runner_name))
    error_message = "runner_name must be a valid Kubernetes resource name"
  }
}

variable "runner_tags" {
  description = "Tags for the runner (used for job matching)"
  type        = list(string)
  default     = []
}

variable "run_untagged" {
  description = "Allow runner to pick up untagged jobs"
  type        = bool
  default     = false
}

variable "locked" {
  description = "Lock runner to project (prevents use in other projects)"
  type        = bool
  default     = true
}

variable "concurrent_jobs" {
  description = "Maximum concurrent jobs the runner can execute"
  type        = number
  default     = 4

  validation {
    condition     = var.concurrent_jobs >= 1 && var.concurrent_jobs <= 100
    error_message = "concurrent_jobs must be between 1 and 100"
  }
}

variable "poll_interval" {
  description = "How often runner checks for new jobs (seconds)"
  type        = number
  default     = 3
}

# =============================================================================
# Kubernetes Configuration
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for runner deployment"
  type        = string
  default     = "gitlab-runners"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "GitLab Runner Helm chart version"
  type        = string
  default     = "0.71.0"
}

# =============================================================================
# Executor Configuration
# =============================================================================

variable "privileged" {
  description = "Run job containers in privileged mode (required for Docker-in-Docker)"
  type        = bool
  default     = false
}

variable "default_image" {
  description = "Default container image for jobs"
  type        = string
  default     = "alpine:latest"
}

variable "image_pull_policy" {
  description = "Image pull policy for job containers"
  type        = string
  default     = "IfNotPresent"

  validation {
    condition     = contains(["Always", "IfNotPresent", "Never"], var.image_pull_policy)
    error_message = "image_pull_policy must be Always, IfNotPresent, or Never"
  }
}

variable "build_dir" {
  description = "Build directory path inside job containers"
  type        = string
  default     = "/builds"
}

variable "cache_dir" {
  description = "Cache directory path inside job containers"
  type        = string
  default     = "/cache"
}

# =============================================================================
# Resource Limits - Runner Manager Pod
# =============================================================================

variable "cpu_request" {
  description = "CPU request for runner manager pod"
  type        = string
  default     = "100m"
}

variable "cpu_limit" {
  description = "CPU limit for runner manager pod"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request for runner manager pod"
  type        = string
  default     = "128Mi"
}

variable "memory_limit" {
  description = "Memory limit for runner manager pod"
  type        = string
  default     = "512Mi"
}

# =============================================================================
# Resource Limits - Helper Container
# =============================================================================

variable "helper_cpu_request" {
  description = "CPU request for helper container"
  type        = string
  default     = "50m"
}

variable "helper_memory_request" {
  description = "Memory request for helper container"
  type        = string
  default     = "64Mi"
}

# =============================================================================
# Resource Limits - Service Container
# =============================================================================

variable "service_cpu_request" {
  description = "CPU request for service containers"
  type        = string
  default     = "50m"
}

variable "service_memory_request" {
  description = "Memory request for service containers"
  type        = string
  default     = "64Mi"
}

# =============================================================================
# RBAC Configuration
# =============================================================================

variable "rbac_create" {
  description = "Create RBAC resources (Role, RoleBinding)"
  type        = bool
  default     = true
}

variable "cluster_wide_access" {
  description = "Grant cluster-wide access (ClusterRole instead of Role)"
  type        = bool
  default     = false
}

variable "service_account_create" {
  description = "Create a service account for the runner"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Service account name (defaults to runner_name)"
  type        = string
  default     = ""
}

# =============================================================================
# Additional Configuration
# =============================================================================

variable "additional_values" {
  description = "Additional Helm values in YAML format (overrides all other settings)"
  type        = string
  default     = ""
}
