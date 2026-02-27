# ARC Runners Stack - Outputs

output "controller_namespace" {
  description = "ARC controller namespace"
  value       = module.arc_controller.namespace
}

output "controller_release" {
  description = "ARC controller Helm release name"
  value       = module.arc_controller.release_name
}

output "nix_runner_label" {
  description = "Nix runner runs-on label"
  value       = module.gh_nix.runner_label
}

output "nix_runner_release" {
  description = "Nix runner Helm release name"
  value       = module.gh_nix.release_name
}

output "docker_runner_label" {
  description = "Docker runner runs-on label"
  value       = var.deploy_docker_runner ? module.gh_docker[0].runner_label : ""
}

output "docker_runner_release" {
  description = "Docker runner Helm release name"
  value       = var.deploy_docker_runner ? module.gh_docker[0].release_name : ""
}

output "dind_runner_label" {
  description = "DinD runner runs-on label"
  value       = var.deploy_dind_runner ? module.gh_dind[0].runner_label : ""
}

output "dind_runner_release" {
  description = "DinD runner Helm release name"
  value       = var.deploy_dind_runner ? module.gh_dind[0].release_name : ""
}

output "runner_namespace" {
  description = "Runner scale sets namespace"
  value       = var.runner_namespace
}

output "extra_runner_labels" {
  description = "Labels for extra runner scale sets"
  value       = { for k, v in module.extra_runners : k => v.runner_label }
}
