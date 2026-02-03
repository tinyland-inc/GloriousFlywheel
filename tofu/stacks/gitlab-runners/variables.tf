# GitLab Runners Stack - Variables

# =============================================================================
# Kubernetes Authentication (GitLab Kubernetes Agent)
# =============================================================================

variable "k8s_config_path" {
  description = "Path to kubeconfig file (usually set by GitLab CI)"
  type        = string
  default     = ""
}

variable "cluster_context" {
  description = "Kubernetes context - GitLab Agent (bates-ils/projects/kubernetes/gitlab-agents:beehive) or local kubeconfig context (beehive)"
  type        = string

  validation {
    condition = can(regex("^(bates-ils/projects/kubernetes/gitlab-agents:)?(beehive|rigel)$", var.cluster_context))
    error_message = "cluster_context must be 'beehive', 'rigel', or full GitLab Agent path"
  }
}

# =============================================================================
# GitLab Configuration
# =============================================================================

variable "gitlab_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_api_token" {
  description = "GitLab API token with create_runner scope for runner registration"
  type        = string
  sensitive   = true
  default     = ""
}

variable "project_id" {
  description = "GitLab project ID for runner registration"
  type        = string
  default     = ""
}

# =============================================================================
# Runner Deployment
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for runner deployment"
  type        = string
  default     = "gitlab-runners"
}

variable "runner_chart_version" {
  description = "GitLab Runner Helm chart version"
  type        = string
  default     = "0.71.0"
}

variable "deploy_k8s_runner" {
  description = "Deploy the K8s runner (for kubectl/tofu deployments)"
  type        = bool
  default     = true
}

# =============================================================================
# Nix Runner Configuration
# =============================================================================

variable "nix_concurrent_jobs" {
  description = "Maximum concurrent jobs for Nix runner"
  type        = number
  default     = 4

  validation {
    condition     = var.nix_concurrent_jobs >= 1 && var.nix_concurrent_jobs <= 20
    error_message = "nix_concurrent_jobs must be between 1 and 20"
  }
}

variable "nix_cpu_request" {
  description = "CPU request for Nix runner manager pod"
  type        = string
  default     = "100m"
}

variable "nix_cpu_limit" {
  description = "CPU limit for Nix runner manager pod"
  type        = string
  default     = "500m"
}

variable "nix_memory_request" {
  description = "Memory request for Nix runner manager pod"
  type        = string
  default     = "128Mi"
}

variable "nix_memory_limit" {
  description = "Memory limit for Nix runner manager pod"
  type        = string
  default     = "512Mi"
}

# =============================================================================
# K8s Runner Configuration
# =============================================================================

variable "k8s_concurrent_jobs" {
  description = "Maximum concurrent jobs for K8s runner"
  type        = number
  default     = 4

  validation {
    condition     = var.k8s_concurrent_jobs >= 1 && var.k8s_concurrent_jobs <= 20
    error_message = "k8s_concurrent_jobs must be between 1 and 20"
  }
}

variable "k8s_cpu_request" {
  description = "CPU request for K8s runner manager pod"
  type        = string
  default     = "100m"
}

variable "k8s_cpu_limit" {
  description = "CPU limit for K8s runner manager pod"
  type        = string
  default     = "500m"
}

variable "k8s_memory_request" {
  description = "Memory request for K8s runner manager pod"
  type        = string
  default     = "256Mi"
}

variable "k8s_memory_limit" {
  description = "Memory limit for K8s runner manager pod"
  type        = string
  default     = "512Mi"
}
