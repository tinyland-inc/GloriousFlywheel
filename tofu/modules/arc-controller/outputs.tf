# ARC Controller Module - Outputs

output "namespace" {
  description = "Namespace where ARC controller is deployed"
  value       = var.namespace
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.arc_controller.name
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.arc_controller.version
}
