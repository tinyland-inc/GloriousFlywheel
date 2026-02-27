---
title: GitHub Actions Runners
order: 15
---

# GitHub Actions Runners

Self-hosted GitHub Actions runners powered by ARC (Actions Runner Controller)
on the same cluster as the GitLab runner pool. Runners access caches via
cluster-internal DNS with zero additional configuration.

## Available Labels

Use these `runs-on` values in your GitHub Actions workflows:

| Label | Runner Type | Use Case |
| --- | --- | --- |
| `tinyland-nix` | nix | Nix builds with Attic binary cache |
| `tinyland-docker` | docker | General CI: linting, testing, builds |
| `tinyland-dind` | dind | Docker-in-Docker: container image builds |

## Quick Start

```yaml
jobs:
  build:
    runs-on: tinyland-nix
    steps:
      - uses: actions/checkout@v4
      - run: nix build
```

No tokens, no registration. The runner pool is available to all repos in the
installed GitHub App organizations.

## Composite Actions

GloriousFlywheel provides composite actions that auto-configure cache endpoints
on self-hosted runners.

### setup-flywheel

Base action that detects the runner environment and configures cache endpoints.
On self-hosted runners, `ATTIC_SERVER`, `ATTIC_CACHE`, and `BAZEL_REMOTE_CACHE`
are set automatically via cluster DNS.

```yaml
steps:
  - uses: tinyland-inc/GloriousFlywheel/.github/actions/setup-flywheel@main
```

### nix-job

Nix build with Attic binary cache. Installs Nix, configures cache, and runs
your command.

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: tinyland-inc/GloriousFlywheel/.github/actions/nix-job@main
    with:
      command: nix build .#default
      push-cache: "true"
```

### docker-job

Standard CI job with Bazel cache configured.

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: tinyland-inc/GloriousFlywheel/.github/actions/docker-job@main
    with:
      command: make build
```

## Cache Integration

ARC runners access caches via cluster-internal DNS. No Ingress, no TLS
overhead, no credential exposure:

- **Attic**: `http://attic-api.nix-cache.svc.cluster.local:8080`
- **Bazel**: `grpc://bazel-cache.nix-cache.svc.cluster.local:9092`

Environment variables are injected automatically:

| Variable | Runner Types | Value |
| --- | --- | --- |
| `ATTIC_SERVER` | nix | Attic API endpoint |
| `ATTIC_CACHE` | nix | Cache name (default: `main`) |
| `BAZEL_REMOTE_CACHE` | nix, docker | Bazel cache gRPC endpoint |
| `NIX_CONFIG` | nix | `experimental-features = nix-command flakes` |

## Architecture

ARC uses a controller + scale set model. The controller watches for
`workflow_job` webhook events and scales runner pods up/down:

```
arc-systems namespace
└── ARC controller (gha-runner-scale-set-controller)

arc-runners namespace
├── gh-nix    (scale set → runs-on: tinyland-nix)
├── gh-docker (scale set → runs-on: tinyland-docker)
└── gh-dind   (scale set → runs-on: tinyland-dind)
```

All scale sets support scale-to-zero. Runner pods are created on demand
when a workflow job matches the `runs-on` label.

## Infrastructure

The ARC stack is managed by OpenTofu:

```bash
cd tofu/stacks/arc-runners
tofu plan -var-file=tinyland.tfvars \
  -var=cluster_context=tinyland-civo-dev \
  -var=k8s_config_path=$HOME/.kube/config
```

## GitHub App Setup

ARC authenticates via a GitHub App installed on the target organizations.
The App requires:

- **Self-hosted runners** (Organization): Read & Write
- **Metadata** (Repository): Read-only
- **Actions** (Repository): Read-only

Webhook event: `workflow_job`

Credentials are stored as a Kubernetes secret in the `arc-systems` namespace.

## See Also

- [Self-Service Enrollment](self-service-enrollment.md) -- GitLab runner enrollment
- [Cache Integration](cache-integration.md) -- cache configuration details
- [Runner Selection](runner-selection.md) -- choosing the right runner type
