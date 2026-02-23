# Runner Cleanup Module - Variables

variable "namespace" {
  description = "Kubernetes namespace where runners operate"
  type        = string
}

variable "schedule" {
  description = "CronJob schedule expression"
  type        = string
  default     = "*/5 * * * *"
}

variable "terminating_threshold_seconds" {
  description = "Force-delete pods stuck in Terminating longer than this (seconds)"
  type        = number
  default     = 300
}

variable "completed_threshold_seconds" {
  description = "Delete Completed pods older than this (seconds)"
  type        = number
  default     = 600
}

variable "failed_threshold_seconds" {
  description = "Delete Failed pods older than this (seconds)"
  type        = number
  default     = 1800
}

variable "kubectl_image" {
  description = "Container image for kubectl"
  type        = string
  default     = "ghcr.io/tinyland-inc/kubectl:1.31"
}

variable "image_pull_secrets" {
  description = "List of image pull secret names for private registries"
  type        = list(string)
  default     = []
}
