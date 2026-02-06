# Bates ILS Runners Stack - Outputs

output "namespace" {
  description = "Namespace where runners are deployed"
  value       = var.namespace
}

# =============================================================================
# Docker Runner
# =============================================================================

output "docker_runner_name" {
  description = "Docker runner name"
  value       = var.deploy_docker_runner ? module.docker_runner[0].runner_name : null
}

output "docker_runner_tags" {
  description = "Docker runner tags"
  value       = var.deploy_docker_runner ? module.docker_runner[0].runner_tags : []
}

# =============================================================================
# DinD Runner
# =============================================================================

output "dind_runner_name" {
  description = "DinD runner name"
  value       = var.deploy_dind_runner ? module.dind_runner[0].runner_name : null
}

output "dind_runner_tags" {
  description = "DinD runner tags"
  value       = var.deploy_dind_runner ? module.dind_runner[0].runner_tags : []
}

# =============================================================================
# Rocky 8 Runner
# =============================================================================

output "rocky8_runner_name" {
  description = "Rocky 8 runner name"
  value       = var.deploy_rocky8_runner ? module.rocky8_runner[0].runner_name : null
}

output "rocky8_runner_tags" {
  description = "Rocky 8 runner tags"
  value       = var.deploy_rocky8_runner ? module.rocky8_runner[0].runner_tags : []
}

# =============================================================================
# Rocky 9 Runner
# =============================================================================

output "rocky9_runner_name" {
  description = "Rocky 9 runner name"
  value       = var.deploy_rocky9_runner ? module.rocky9_runner[0].runner_name : null
}

output "rocky9_runner_tags" {
  description = "Rocky 9 runner tags"
  value       = var.deploy_rocky9_runner ? module.rocky9_runner[0].runner_tags : []
}

# =============================================================================
# Nix Runner
# =============================================================================

output "nix_runner_name" {
  description = "Nix runner name"
  value       = var.deploy_nix_runner ? module.nix_runner[0].runner_name : null
}

output "nix_runner_tags" {
  description = "Nix runner tags"
  value       = var.deploy_nix_runner ? module.nix_runner[0].runner_tags : []
}

# =============================================================================
# Summary
# =============================================================================

output "deployed_runners" {
  description = "List of deployed runners"
  value = compact([
    var.deploy_docker_runner ? "bates-docker" : "",
    var.deploy_dind_runner ? "bates-dind" : "",
    var.deploy_rocky8_runner ? "bates-rocky8" : "",
    var.deploy_rocky9_runner ? "bates-rocky9" : "",
    var.deploy_nix_runner ? "bates-nix" : "",
  ])
}

output "hpa_enabled" {
  description = "Whether HPA is enabled"
  value       = var.hpa_enabled
}

output "service_monitor_enabled" {
  description = "Whether ServiceMonitor is enabled"
  value       = var.service_monitor_enabled
}
