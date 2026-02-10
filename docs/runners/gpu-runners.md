---
title: GPU Runners
order: 15
---

# GPU Runners

The GitLab runner module supports two GPU runner types: `l40s` and `a100`.

## Prerequisites

1. **NVIDIA GPU Operator** installed on the cluster
2. **GPU node pool** with appropriate labels and taints
3. Nodes visible via `kubectl get nodes -l accelerator=nvidia`

## Runner Types

| Type | GPU | Architecture | VRAM | Use Case |
|------|-----|-------------|------|----------|
| `l40s` | NVIDIA L40S | Ada Lovelace | 48 GB | Inference, fine-tuning, rendering |
| `a100` | NVIDIA A100 | Ampere | 40/80 GB | Training, large model inference |

Both types default to `nvidia/cuda:12.4-devel-ubuntu22.04` and run in
privileged mode for GPU device access.

## Configuration

```hcl
module "gpu_runner" {
  source = "../../modules/gitlab-runner"

  runner_name  = "gpu-l40s"
  runner_type  = "l40s"
  runner_token = var.l40s_runner_token
  namespace    = "gitlab-runners"

  # GPU configuration
  gpu_count         = 1
  gpu_resource_name = "nvidia.com/gpu"

  gpu_node_selector = {
    "kubernetes.civo.com/node-pool" = "gpu"
  }

  gpu_tolerations = [{
    key      = "nvidia.com/gpu"
    operator = "Exists"
    value    = null
    effect   = "NoSchedule"
  }]

  # Scale conservatively — GPU nodes are expensive
  concurrent_jobs = 2
  hpa_enabled     = true
  hpa_min_replicas = 1
  hpa_max_replicas = 2
}
```

## CI Job Example

```yaml
train-model:
  tags: [gpu, nvidia, cuda, l40s]
  image: nvidia/cuda:12.4-devel-ubuntu22.04
  script:
    - nvidia-smi
    - python train.py --epochs 10
```

## How GPU Allocation Works

The module injects a `pod_spec` strategic merge patch into the runner TOML
config. This adds `nvidia.com/gpu` resource requests/limits to the `build`
container in each CI job pod. The Kubernetes scheduler then places job pods
on nodes with available GPUs.

## Environment Variables

GPU runners automatically inject:

- `NVIDIA_VISIBLE_DEVICES=all` — expose all GPUs to the container
- `NVIDIA_DRIVER_CAPABILITIES=compute,utility` — enable compute + nvidia-smi

## Troubleshooting

### Job pod stuck in Pending

Check that GPU nodes are available and the NVIDIA device plugin is running:

```bash
kubectl get nodes -l accelerator=nvidia
kubectl get pods -n gpu-operator -l app=nvidia-device-plugin-daemonset
```

### nvidia-smi not found

Ensure the NVIDIA GPU Operator is installed and the driver container is
running on GPU nodes:

```bash
kubectl get pods -n gpu-operator
```

### Wrong number of GPUs

Adjust `gpu_count` in the module configuration. Each job pod requests
exactly that many GPUs.
