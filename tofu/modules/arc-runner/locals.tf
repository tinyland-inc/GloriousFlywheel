# ARC Runner Module - Local Variables
#
# Computed values based on runner type and configuration.

locals {
  # =============================================================================
  # Runner Type Defaults
  # =============================================================================

  # Default images per runner type (mirrors gitlab-runner types)
  runner_type_images = {
    docker = "alpine:3.21"
    dind   = "docker:27-dind"
    nix    = "docker.nix-community.org/nixpkgs/nix-flakes:nixos-unstable"
  }

  # Container mode per runner type
  runner_type_container_mode = {
    docker = "kubernetes"
    dind   = "dind"
    nix    = "kubernetes"
  }

  # =============================================================================
  # Computed Values
  # =============================================================================

  container_mode = var.container_mode != "" ? var.container_mode : local.runner_type_container_mode[var.runner_type]

  # =============================================================================
  # Environment Variables
  # =============================================================================

  # Cache environment variables injected into runner pods
  cache_env_vars = concat(
    var.runner_type == "nix" && var.attic_server != "" ? [
      { name = "NIX_CONFIG", value = "experimental-features = nix-command flakes" },
      { name = "ATTIC_SERVER", value = var.attic_server },
      { name = "ATTIC_CACHE", value = var.attic_cache },
    ] : [],
    var.bazel_cache_endpoint != "" && contains(["docker", "nix"], var.runner_type) ? [
      { name = "BAZEL_REMOTE_CACHE", value = var.bazel_cache_endpoint },
    ] : [],
    local.container_mode == "dind" ? [
      { name = "DOCKER_HOST", value = "tcp://localhost:2375" },
      { name = "DOCKER_TLS_CERTDIR", value = "" },
    ] : [],
  )

  # Merge computed env vars with user-supplied extras
  all_env_vars = concat(local.cache_env_vars, var.env_vars)

  # =============================================================================
  # Labels
  # =============================================================================

  common_labels = {
    "app.kubernetes.io/name"        = "arc-runner"
    "app.kubernetes.io/instance"    = var.runner_name
    "app.kubernetes.io/managed-by"  = "opentofu"
    "app.kubernetes.io/component"   = "runner-scale-set"
    "app.kubernetes.io/runner-type" = var.runner_type
  }
}
