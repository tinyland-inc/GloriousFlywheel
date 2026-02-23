#!/usr/bin/env bash
# Mirror Docker Hub images to GitLab Container Registry.
# Reads ci/images.yml manifest and copies each image via crane.
set -euo pipefail

REGISTRY="${CI_REGISTRY_IMAGE:-registry.gitlab.com/tinyland/GloriousFlywheel}"

echo "=== Docker Hub -> GitLab Registry Mirror ==="
echo "Target registry: $REGISTRY"
echo ""

# Authenticate to GitLab Container Registry
if [ -n "${CI_REGISTRY_USER:-}" ] && [ -n "${CI_REGISTRY_PASSWORD:-}" ]; then
  crane auth login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" registry.gitlab.com
else
  echo "WARNING: CI_REGISTRY_USER/CI_REGISTRY_PASSWORD not set, skipping auth"
fi

FAILURES=0

while IFS='|' read -r src dest; do
  echo "--- $src -> $REGISTRY/$dest ---"
  if crane copy "$src" "$REGISTRY/$dest"; then
    echo "OK: $src"
  else
    echo "RETRY: $src (waiting 10s)"
    sleep 10
    if crane copy "$src" "$REGISTRY/$dest"; then
      echo "OK (retry): $src"
    else
      echo "FAIL: $src"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  echo ""
done < <(yq -r '.mirrors[] | .source + "|" + .dest' ci/images.yml)

if [ "$FAILURES" -gt 0 ]; then
  echo "=== $FAILURES image(s) failed to mirror ==="
  exit 1
fi

echo "=== All images mirrored successfully ==="
