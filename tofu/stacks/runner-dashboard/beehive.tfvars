# Beehive Cluster - Runner Dashboard Configuration
#
# Development environment configuration for the runner dashboard.
# Uses GitLab Kubernetes Agent for authentication.

cluster_context = "bates-ils/projects/kubernetes/gitlab-agents:beehive"
namespace       = "runner-dashboard"

# =============================================================================
# Container Image
# =============================================================================

image = "registry.gitlab.com/bates-ils/runner-dashboard:latest"

# =============================================================================
# GitLab OAuth (set via CI/CD variables or TF_VAR_ env vars)
# =============================================================================
# gitlab_oauth_client_id     = (set via TF_VAR_gitlab_oauth_client_id)
# gitlab_oauth_client_secret = (set via TF_VAR_gitlab_oauth_client_secret)
# gitlab_token               = (set via TF_VAR_gitlab_token)

gitlab_url                = "https://gitlab.com"
gitlab_oauth_redirect_uri = "https://runner-dashboard.beehive.bates.edu/auth/callback"

# =============================================================================
# Prometheus
# =============================================================================

prometheus_url = "http://prometheus.monitoring.svc.cluster.local:9090"

# =============================================================================
# Runner Namespace
# =============================================================================

runners_namespace = "bates-ils-runners"

# =============================================================================
# Deployment Configuration
# =============================================================================

replicas = 1
node_env = "production"

# =============================================================================
# Resource Limits (minimal for dev)
# =============================================================================

cpu_request    = "50m"
memory_request = "64Mi"
cpu_limit      = "500m"
memory_limit   = "256Mi"

# =============================================================================
# Ingress Configuration
# =============================================================================

enable_ingress      = true
ingress_host        = "runner-dashboard.beehive.bates.edu"
ingress_class       = "nginx"
enable_tls          = true
cert_manager_issuer = "letsencrypt-prod"

# =============================================================================
# Monitoring
# =============================================================================

enable_prometheus_scrape = true
