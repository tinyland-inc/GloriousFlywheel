#!/usr/bin/env bash
# scripts/validate-org-config.sh - Validate organization config

set -euo pipefail

CONFIG_FILE="${1:-config/organization.yaml}"

echo "Validating organization config: $CONFIG_FILE"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

# Validate required fields
required_fields=(
  ".organization.name"
  ".organization.group_path"
  ".gitlab.project_id"
  ".gitlab.agent_group"
  ".clusters[0].name"
  ".clusters[0].domain"
  ".clusters[0].context"
)

for field in "${required_fields[@]}"; do
  value=$(yq "$field" "$CONFIG_FILE")
  if [ "$value" = "null" ] || [ -z "$value" ]; then
    echo "❌ Missing required field: $field"
    exit 1
  fi
done

# Validate cluster contexts match pattern
for context in $(yq '.clusters[].context' "$CONFIG_FILE"); do
  if ! echo "$context" | grep -qE '^[a-z0-9-]+/[^:]+:[a-z0-9-]+$'; then
    echo "❌ Invalid cluster context format: $context"
    echo "   Expected: group/path:agent (e.g., mygroup/kubernetes/agents:dev)"
    exit 1
  fi
done

echo "✅ Organization config is valid"
