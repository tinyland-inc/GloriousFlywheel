# ARC Runner Module - Outputs

output "release_name" {
  description = "Helm release name"
  value       = helm_release.arc_runner.name
}

output "runner_label" {
  description = "GitHub Actions runs-on label"
  value       = var.runner_label
}

output "namespace" {
  description = "Namespace where runner scale set is deployed"
  value       = var.namespace
}

output "runner_type" {
  description = "Runner type (docker, dind, nix)"
  value       = var.runner_type
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.arc_runner.version
}
