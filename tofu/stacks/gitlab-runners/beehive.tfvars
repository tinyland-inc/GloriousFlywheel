# Beehive Cluster - GitLab Runners Configuration
#
# Development/review cluster runners for Bates ILS.
# Uses GitLab Kubernetes Agent for authentication.

# =============================================================================
# Cluster & Namespace
# =============================================================================

cluster_context = "bates-ils/projects/kubernetes/gitlab-agents:beehive"
namespace       = "gitlab-runners"

# =============================================================================
# GitLab Configuration
# =============================================================================

gitlab_url = "https://gitlab.com"
# gitlab_api_token and project_id should be set via environment variables:
#   TF_VAR_gitlab_api_token - GitLab API token with create_runner scope
#   TF_VAR_project_id       - GitLab project ID

# =============================================================================
# Runner Deployment
# =============================================================================

runner_chart_version = "0.71.0"
deploy_k8s_runner    = true

# =============================================================================
# Nix Runner Configuration
# =============================================================================
# Primary runner for Nix build jobs with tags: nix, kubernetes

nix_concurrent_jobs = 4
nix_cpu_request     = "100m"
nix_memory_request  = "128Mi"
nix_cpu_limit       = "500m"
nix_memory_limit    = "512Mi"

# =============================================================================
# K8s Runner Configuration
# =============================================================================
# Secondary runner for deployments with tags: kubernetes, tofu, kubectl

k8s_concurrent_jobs = 4
k8s_cpu_request     = "100m"
k8s_memory_request  = "256Mi"
k8s_cpu_limit       = "500m"
k8s_memory_limit    = "512Mi"
