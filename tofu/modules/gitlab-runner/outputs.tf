# GitLab Runner Module - Outputs

output "runner_name" {
  description = "Name of the deployed runner"
  value       = var.runner_name
}

output "namespace" {
  description = "Kubernetes namespace where runner is deployed"
  value       = var.namespace
}

output "runner_tags" {
  description = "Tags assigned to the runner"
  value       = var.runner_tags
}

output "helm_release_name" {
  description = "Helm release name"
  value       = helm_release.gitlab_runner.name
}

output "helm_release_version" {
  description = "Helm chart version"
  value       = helm_release.gitlab_runner.version
}

output "runner_registered_via_api" {
  description = "Whether runner was registered via GitLab API"
  value       = var.gitlab_api_token != "" && var.project_id != ""
  sensitive   = true
}

output "concurrent_jobs" {
  description = "Maximum concurrent jobs"
  value       = var.concurrent_jobs
}

output "privileged" {
  description = "Whether runner runs privileged containers"
  value       = var.privileged
}

output "cluster_wide_access" {
  description = "Whether runner has cluster-wide RBAC access"
  value       = var.cluster_wide_access
}
