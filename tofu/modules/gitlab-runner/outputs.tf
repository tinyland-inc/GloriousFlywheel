# GitLab Runner Module - Outputs

output "namespace" {
  description = "Namespace where runner is deployed"
  value       = var.namespace
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.gitlab_runner.name
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.gitlab_runner.version
}

output "runner_name" {
  description = "Runner name"
  value       = var.runner_name
}

output "runner_type" {
  description = "Runner type (docker, dind, rocky8, rocky9, nix)"
  value       = var.runner_type
}

output "runner_tags" {
  description = "Runner tags (computed)"
  value       = local.runner_tags
}

output "default_image" {
  description = "Default container image for jobs"
  value       = local.default_image
}

output "privileged" {
  description = "Whether runner runs in privileged mode"
  value       = local.privileged
}

output "hpa_enabled" {
  description = "Whether HPA is enabled"
  value       = var.hpa_enabled
}

output "service_monitor_enabled" {
  description = "Whether ServiceMonitor is enabled"
  value       = var.service_monitor_enabled
}

output "concurrent_jobs" {
  description = "Maximum concurrent jobs per manager pod"
  value       = var.concurrent_jobs
}
