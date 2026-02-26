---
title: Dashboard Overview
order: 1
---

# Runner Dashboard Overview

The runner dashboard is a SvelteKit 5 application that provides real-time
monitoring of the cross-forge runner pool.

## Architecture

- **Framework**: SvelteKit 5 + Skeleton v4 + adapter-node
- **Source**: `app/`
- **Infrastructure**: `tofu/modules/runner-dashboard/` + `tofu/stacks/runner-dashboard/`

## Features

- **Cross-forge monitoring**: View GitLab CI and GitHub Actions runners in a
  unified interface with forge badges (GL/GH)
- **HPA status**: Live replica counts, CPU/memory utilization, scaling events
  for GitLab runners
- **ARC autoscaler views**: Scale set status, active/idle/pending runner
  counts for GitHub Actions runners with scale-to-zero labels
- **Drift detection**: Alerts when deployed state diverges from tofu state
- **Forge filter**: Toggle between All, GitLab, and GitHub runner views

## Multi-Namespace Queries

The dashboard queries multiple Kubernetes namespaces:

- `gitlab-runners` -- GitLab runner pods, HPAs, deployments
- `arc-runners` -- ARC runner scale sets, runner pods

Namespaces are configured via the `K8S_RUNNER_NAMESPACES` environment
variable. ARC namespaces additionally query `AutoScalingRunnerSet` CRDs
from `actions.github.com/v1alpha1`.

RBAC is configured as a ClusterRole with dynamic RoleBindings for each
namespace.

## Prometheus Integration

PromQL queries pull metrics from the cluster Prometheus instance for
historical utilization data, scaling event timelines, and cache hit rates.

Prometheus URL is configured via `PROMETHEUS_URL` in the runner-dashboard
module.

## Authentication

- **GitLab OAuth**: Primary login via GitLab OAuth2 flow
- **WebAuthn / FIDO2**: Optional passwordless authentication backed by
  a PostgreSQL credential store (`webauthn-db` module)

## Caddy Sidecar Proxy

The dashboard module supports an optional Caddy reverse proxy sidecar with
two modes:

- **mTLS mode**: Client certificate authentication with a custom CA
- **Tailscale mode**: Automatic TLS via Tailscale MagicDNS

Configure via `enable_caddy_proxy`, `caddy_mode`, and related variables
in the runner-dashboard module.

## Development

```bash
cd app
pnpm install
pnpm dev          # Start dev server
pnpm check        # Type check
pnpm test         # Run tests
pnpm build        # Production build
```

## See Also

- [OpenTofu Modules](../reference/tofu-modules.md#runner-dashboard) -- deployment configuration
- [Runners Overview](../runners/README.md) -- the runner pool this dashboard monitors
