# ARC Controller Module - Variables

# =============================================================================
# Namespace Configuration
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for ARC controller"
  type        = string
  default     = "arc-systems"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

# =============================================================================
# Helm Configuration
# =============================================================================

variable "release_name" {
  description = "Helm release name for ARC controller"
  type        = string
  default     = "arc-controller"
}

variable "chart_version" {
  description = "ARC controller Helm chart version"
  type        = string
  default     = "0.13.1"
}

# =============================================================================
# Controller Resources
# =============================================================================

variable "cpu_request" {
  description = "CPU request for controller pod"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request for controller pod"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit for controller pod"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "Memory limit for controller pod"
  type        = string
  default     = "256Mi"
}

# =============================================================================
# Image Configuration
# =============================================================================

variable "image_pull_secrets" {
  description = "Image pull secrets for controller pods"
  type        = list(string)
  default     = []
}

# =============================================================================
# Controller Settings
# =============================================================================

variable "log_level" {
  description = "Controller log level"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be one of: debug, info, warn, error"
  }
}

variable "update_strategy" {
  description = "Controller update strategy (immediate or eventual)"
  type        = string
  default     = "eventual"

  validation {
    condition     = contains(["immediate", "eventual"], var.update_strategy)
    error_message = "update_strategy must be one of: immediate, eventual"
  }
}
