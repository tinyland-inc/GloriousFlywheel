#!/usr/bin/env bash
# scripts/lib/config.sh - Organization config loader

load_org_config() {
  local config_file="${1:-config/organization.yaml}"

  if [ ! -f "$config_file" ]; then
    echo "ERROR: Organization config not found: $config_file" >&2
    echo "Copy config/organization.example.yaml to config/organization.yaml" >&2
    return 1
  fi

  # Validate yq is available
  if ! command -v yq &>/dev/null; then
    echo "ERROR: yq is required for config parsing" >&2
    echo "Install: brew install yq" >&2
    return 1
  fi

  # Export org identity
  export ORG_NAME=$(yq '.organization.name' "$config_file")
  export ORG_FULL_NAME=$(yq '.organization.full_name' "$config_file")
  export ORG_GROUP_PATH=$(yq '.organization.group_path' "$config_file")

  # Export GitLab config
  export GITLAB_URL=$(yq '.gitlab.url' "$config_file")
  export GITLAB_PROJECT_ID=$(yq '.gitlab.project_id' "$config_file")
  export GITLAB_AGENT_GROUP=$(yq '.gitlab.agent_group' "$config_file")
}

get_cluster_context() {
  local env="${1:-dev}"
  local config_file="${2:-config/organization.yaml}"
  yq ".clusters[] | select(.name == \"$env\") | .context" "$config_file"
}

get_cluster_domain() {
  local env="${1:-dev}"
  local config_file="${2:-config/organization.yaml}"
  yq ".clusters[] | select(.name == \"$env\") | .domain" "$config_file"
}

get_namespace() {
  local component="$1"  # attic or runners
  local env="$2"        # dev, staging, prod
  local config_file="${3:-config/organization.yaml}"

  if [ "$component" = "runners" ]; then
    yq ".namespaces.runners.all" "$config_file"
  else
    yq ".namespaces.attic.$env" "$config_file"
  fi
}
