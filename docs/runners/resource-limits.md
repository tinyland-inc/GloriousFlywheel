# Resource Limits Reference

Default resource limits for CI job pods, by runner type.

## Default Job Pod Limits

These are the module defaults. Overlay deployments (e.g., Bates) override these
values in their `*.tfvars` files.

| Runner | CPU Request | CPU Limit | Memory Request | Memory Limit |
|--------|------------|-----------|----------------|--------------|
| docker | 100m | 2 | 256Mi | 2Gi |
| dind | 500m | 4 | 1Gi | 8Gi |
| rocky8 | 100m | 2 | 256Mi | 2Gi |
| rocky9 | 100m | 2 | 256Mi | 2Gi |
| nix | 500m | 4 | 1Gi | 8Gi |

## Typical Workload Profiles

| Workload | CPU (typical) | Memory (typical) | Recommended Runner |
|----------|--------------|------------------|-------------------|
| Python lint (ruff) | 50-200m | 128-256Mi | docker |
| Python tests (pytest) | 100-500m | 256-512Mi | docker |
| Nix flake check | 200-500m | 256-512Mi | nix |
| GHC build (warm cache) | 500m-1 | 512Mi-1Gi | nix |
| GHC build (cold cache) | 2-4 | 2-4Gi | nix |
| MUSL static build | 1-2 | 1-2Gi | nix |
| FPM RPM packaging | 100-500m | 256-512Mi | rocky8/rocky9 |
| Docker image build | 500m-2 | 512Mi-2Gi | dind |

## Namespace Quota

The runner namespace has a total resource quota shared across all concurrent job pods:

| Resource | Default | Description |
|----------|---------|-------------|
| CPU requests | 16 | Total CPU requests across all pods |
| Memory requests | 32Gi | Total memory requests across all pods |
| Max pods | 50 | Maximum concurrent pods |

## Requesting Limit Increases

If your jobs are being OOM-killed or throttled:

1. Check pod resource usage: `kubectl top pods -n <runner-namespace>`
2. Review the job logs for OOM or throttling messages
3. Update the overlay `*.tfvars` file with higher limits for the relevant runner type
4. Run `tofu plan` and `tofu apply` to apply changes
5. The runner Helm release will be updated with new pod resource templates
