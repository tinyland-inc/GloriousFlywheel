output "nix_runner_namespace" {
  description = "Namespace for runners"
  value       = module.nix_runner.namespace
}

output "nix_runner_release" {
  description = "Nix runner Helm release name"
  value       = module.nix_runner.release_name
}

output "docker_runner_release" {
  description = "Docker runner Helm release name"
  value       = var.deploy_docker_runner ? module.docker_runner[0].release_name : ""
}

output "dind_runner_release" {
  description = "DinD runner Helm release name"
  value       = var.deploy_dind_runner ? module.dind_runner[0].release_name : ""
}
