# Runner Security Model

Security controls applied to the bates-ils HPA runner pool.

## Overview

Each CI job (except dind) runs in an ephemeral Kubernetes namespace with
network isolation, resource limits, and restricted RBAC. Namespaces are
created at job start and cleaned up after completion, with a CronJob as a
safety net for orphans.

## Namespace-Per-Job Isolation

Runners with `namespace_per_job` enabled create a unique `ci-job-*` namespace
for each pipeline job:

| Runner | namespace_per_job | Reason                                     |
| ------ | ----------------- | ------------------------------------------ |
| docker | yes               | Standard isolation                         |
| rocky8 | yes               | Standard isolation                         |
| rocky9 | yes               | Standard isolation                         |
| nix    | yes               | Standard isolation                         |
| dind   | **no**            | Requires shared Docker daemon (privileged) |

Each ephemeral namespace is provisioned with the security resources described
below.

## NetworkPolicy

**Policy**: default-deny ingress, allow-all egress.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

- No pod in the job namespace can receive inbound traffic from other namespaces
  or pods.
- Full egress is allowed so jobs can pull images, fetch dependencies, and push
  artifacts.

## ResourceQuota

Each ephemeral namespace is capped:

| Resource          | Limit |
| ----------------- | ----- |
| CPU (requests)    | 16    |
| Memory (requests) | 32Gi  |
| Pods              | 50    |

This prevents a single job from consuming the entire node. Jobs exceeding the
quota will fail to schedule with an event explaining the limit.

## LimitRange

Default and maximum container resource boundaries:

| Setting         | CPU  | Memory |
| --------------- | ---- | ------ |
| Default request | 100m | 128Mi  |
| Default limit   | 1    | 1Gi    |
| Max limit       | 4    | 8Gi    |

Containers without explicit resource requests/limits get the defaults.
Containers requesting more than the max are rejected at admission.

## RBAC

A `ci-job-runner-access` Role is created in each ephemeral namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-job-runner-access
rules:
  - apiGroups: ["", "apps", "autoscaling", "batch"]
    resources:
      - pods
      - deployments
      - horizontalpodautoscalers
      - jobs
      - events
    verbs: [get, list, watch]
```

The job service account is bound to this role. Jobs can **read** cluster state
for debugging and status checks but cannot create, modify, or delete resources.

Deployments to the cluster go through the `k8s-deploy` component, which uses
the GitLab Agent `ci_access` path with its own RBAC (separate from the job
namespace).

## DinD Exception

The `dind` runner is the deliberate exception to namespace-per-job isolation:

- Runs in a **shared namespace** (`bates-ils-runners`).
- Requires **privileged** mode for the Docker daemon sidecar.
- No ephemeral namespace creation or teardown.

**Mitigations**:

- DinD jobs are tagged `privileged` -- only pipelines that explicitly request
  the tag use this runner.
- The Docker daemon runs as a sidecar per pod, not as a shared cluster-wide
  daemon.
- Image pull policies and resource limits still apply at the pod level.

Use `dind` only for container image builds. For everything else, use `docker`.

## Orphaned Namespace Cleanup

A `CronJob` runs on a schedule (default: every 15 minutes) to garbage-collect
`ci-job-*` namespaces that were not cleaned up by the runner:

- Namespaces older than a configurable TTL (default: 1 hour) are deleted.
- The CronJob runs in the `bates-ils-runners` namespace with a service account
  that has permission to list and delete namespaces matching `ci-job-*`.
- Logs are emitted for each namespace deleted.

This handles edge cases like runner pod crashes, node failures, or network
partitions that prevent normal cleanup.

## Pod Security Admission

The `bates-ils-runners` namespace carries PSA labels:

```yaml
metadata:
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

- **enforce: baseline** -- blocks known-dangerous pod configurations (e.g.,
  hostPath, hostNetwork) except for the dind runner which is explicitly
  exempted.
- **audit: restricted** -- logs violations against the strictest profile.
- **warn: restricted** -- shows warnings for restricted-profile violations
  without blocking.

Ephemeral `ci-job-*` namespaces inherit the same PSA labels.
