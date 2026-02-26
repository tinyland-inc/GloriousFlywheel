---
title: GitHub App Adoption
order: 1
---

# GitHub App Adoption

GloriousFlywheel uses a GitHub App to authenticate ARC (Actions Runner
Controller) with GitHub. This guide explains how to install the app on
your organization and configure runner access.

## What is GloriousFlywheel?

GloriousFlywheel is a GitHub App (ID 2953466) that enables self-hosted
GitHub Actions runners via ARC. It listens for `workflow_job` webhook
events and scales runner pods on demand.

## Install on a New Organization

1. Navigate to the GitHub App settings page
2. Click **Install** and select the target organization
3. Choose **All repositories** or select specific repos
4. Approve the installation

### Required Permissions

| Permission | Scope | Access |
|-----------|-------|--------|
| Self-hosted runners | Organization | Read & Write |
| Metadata | Repository | Read-only |
| Actions | Repository | Read-only |

### Webhook Events

The app subscribes to `workflow_job` events. These trigger runner
pod creation when a job matches a self-hosted runner label.

## Kubernetes Secret Setup

ARC authenticates using a Kubernetes secret containing the GitHub App
credentials. This secret **must exist in both namespaces**:

- `arc-systems` -- used by the ARC controller for API authentication
- `arc-runners` -- used by runner scale sets for registration

```bash
# Create the secret in both namespaces
for ns in arc-systems arc-runners; do
  kubectl create secret generic github-app-secret \
    --namespace="$ns" \
    --from-literal=github_app_id=2953466 \
    --from-literal=github_app_installation_id=<INSTALLATION_ID> \
    --from-file=github_app_pem=<PATH_TO_PEM_FILE>
done
```

## Runner Group Configuration

The default runner group must allow public repositories if you want
self-hosted runners available to public repos:

```bash
gh api -X PATCH /orgs/<ORG>/actions/runner-groups/1 \
  -f allows_public_repositories=true
```

Without this, workflows in public repos will fail to match self-hosted
runner labels.

## Deploy the ARC Stack

```bash
cd tofu/stacks/arc-runners
tofu init
tofu plan -var-file=tinyland.tfvars \
  -var=cluster_context=tinyland-civo-dev \
  -var=k8s_config_path=$HOME/.kube/config
tofu apply -var-file=tinyland.tfvars \
  -var=cluster_context=tinyland-civo-dev \
  -var=k8s_config_path=$HOME/.kube/config
```

This deploys:
- ARC controller in `arc-systems`
- Three runner scale sets (gh-nix, gh-docker, gh-dind) in `arc-runners`

## Composite Actions

GloriousFlywheel provides composite actions that auto-configure cache
endpoints on self-hosted runners:

| Action | Description |
|--------|------------|
| `setup-flywheel` | Detect runner environment, configure cache endpoints |
| `nix-job` | Nix build with Attic binary cache |
| `docker-job` | Standard CI job with Bazel cache |

### Usage

```yaml
jobs:
  build:
    runs-on: tinyland-nix
    steps:
      - uses: actions/checkout@v4
      - uses: tinyland-inc/GloriousFlywheel/.github/actions/nix-job@main
        with:
          command: nix build .#default
          push-cache: "true"
```

## Workflow Examples

### Simple Nix Build

```yaml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: tinyland-nix
    steps:
      - uses: actions/checkout@v4
      - run: nix build
```

### Docker Build

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: tinyland-docker
    steps:
      - uses: actions/checkout@v4
      - run: make test

  build-image:
    runs-on: tinyland-dind
    needs: test
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t myapp .
```

## See Also

- [GitHub Actions Runners](../runners/github-actions.md) -- runner labels, cache integration, architecture
- [Cross-Forge CI](cross-forge-ci.md) -- GitLab CI vs GitHub Actions comparison
- [Runner Selection Guide](../runners/runner-selection.md) -- choosing the right runner type
