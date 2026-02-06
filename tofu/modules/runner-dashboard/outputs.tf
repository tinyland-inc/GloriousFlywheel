# Runner Dashboard Module - Outputs

# =============================================================================
# Deployment Outputs
# =============================================================================

output "deployment_name" {
  description = "Name of the Kubernetes deployment"
  value       = kubernetes_deployment.dashboard.metadata[0].name
}

output "deployment_namespace" {
  description = "Namespace of the deployment"
  value       = local.namespace_name
}

output "deployment_labels" {
  description = "Labels applied to the deployment"
  value       = local.labels
}

# =============================================================================
# Service Outputs
# =============================================================================

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.dashboard.metadata[0].name
}

output "service_endpoint" {
  description = "Internal service endpoint (service.namespace.svc.cluster.local)"
  value       = "${kubernetes_service.dashboard.metadata[0].name}.${local.namespace_name}.svc.cluster.local"
}

output "service_port" {
  description = "Service port number"
  value       = var.service_port
}

# =============================================================================
# Ingress Outputs
# =============================================================================

output "ingress_enabled" {
  description = "Whether ingress is enabled"
  value       = var.enable_ingress
}

output "ingress_host" {
  description = "Ingress hostname (if enabled)"
  value       = var.enable_ingress ? var.ingress_host : null
}

output "ingress_url" {
  description = "Full URL for the ingress (if enabled)"
  value       = var.enable_ingress && var.enable_tls ? "https://${var.ingress_host}" : (var.enable_ingress ? "http://${var.ingress_host}" : null)
}

# =============================================================================
# RBAC Outputs
# =============================================================================

output "service_account_name" {
  description = "Name of the service account used by the dashboard"
  value       = kubernetes_service_account.dashboard.metadata[0].name
}

output "cluster_role_name" {
  description = "Name of the ClusterRole for runner namespace access"
  value       = kubernetes_cluster_role.dashboard_reader.metadata[0].name
}

# =============================================================================
# Health Check Outputs
# =============================================================================

output "health_check_config" {
  description = "Health check configuration"
  value = {
    path           = var.health_check_path
    container_port = var.container_port
  }
}

# =============================================================================
# Resource Configuration
# =============================================================================

output "resource_config" {
  description = "Resource requests and limits configuration"
  value = {
    cpu_request    = var.cpu_request
    cpu_limit      = var.cpu_limit
    memory_request = var.memory_request
    memory_limit   = var.memory_limit
  }
}
