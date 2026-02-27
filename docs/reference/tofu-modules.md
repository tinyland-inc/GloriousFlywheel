---
title: OpenTofu Modules
order: 1
---

# OpenTofu Modules

All reusable infrastructure modules live in `tofu/modules/`. Each module is
designed to be composed by stack root configurations in `tofu/stacks/`.

There are 15 modules organized by function: runner infrastructure, cache
platform, Kubernetes primitives, and operators.

## Runner Infrastructure

### arc-controller

Deploys the GitHub Actions Runner Controller (ARC) via Helm chart. The
controller watches for `workflow_job` webhook events and manages runner
scale sets.

- **Path**: `tofu/modules/arc-controller/`
- **Key variables**: `namespace`, `chart_version`, `image_pull_secrets`
- **Outputs**: `namespace`, `release_name`, `chart_version`

### arc-runner

Deploys a GitHub Actions runner scale set via ARC. Supports docker, dind,
and nix runner types with scale-to-zero.

- **Path**: `tofu/modules/arc-runner/`
- **Key variables**: `runner_name`, `runner_label`, `runner_type`, `github_config_url`, `github_config_secret`, `min_runners`, `max_runners`
- **Outputs**: `release_name`, `runner_label`, `runner_type`

### gitlab-runner

Deploys a GitLab Runner via Helm chart with HPA support. Supports docker,
dind, and nix runner types with configurable autoscaling, monitoring, and
namespace-per-job isolation.

- **Path**: `tofu/modules/gitlab-runner/`
- **Key variables**: `runner_token`, `runner_name`, `runner_type`, `runner_tags`, `hpa_enabled`, `hpa_min_replicas`, `hpa_max_replicas`
- **Outputs**: `release_name`, `runner_type`, `runner_tags`, `hpa_enabled`

### gitlab-user-runner

Registers a GitLab Runner via the `gitlab_user_runner` resource, automating
token lifecycle management.

- **Path**: `tofu/modules/gitlab-user-runner/`
- **Key variables**: `group_id`, `tag_list`, `description`
- **Outputs**: `token`, `runner_id`

### runner-dashboard

Deploys the SvelteKit runner dashboard with OAuth login, Prometheus metrics,
multi-namespace RBAC, and optional Caddy sidecar proxy.

- **Path**: `tofu/modules/runner-dashboard/`
- **Key variables**: `image`, `namespace`, `gitlab_oauth_client_id`, `prometheus_url`, `runners_namespace`, `arc_namespaces`, `enable_caddy_proxy`
- **Outputs**: `deployment_name`, `service_endpoint`, `ingress_url`

### runner-cleanup

CronJob that reaps orphaned and stuck pods (Terminating, Completed, Failed)
in the runner namespace.

- **Path**: `tofu/modules/runner-cleanup/`
- **Key variables**: `namespace`, `schedule`, `terminating_threshold_seconds`

### runner-security

Applies security policies to the runner namespace: default-deny
NetworkPolicy, ResourceQuota, LimitRange, and PriorityClasses.

- **Path**: `tofu/modules/runner-security/`
- **Key variables**: `namespace`, `quota_cpu_requests`, `quota_memory_requests`, `priority_classes_enabled`
- **Outputs**: `manager_priority_class_name`, `job_priority_class_name`

### gitlab-agent-rbac

Configures Kubernetes RBAC for GitLab Agent `ci_access` impersonation with
read-only runner access.

- **Path**: `tofu/modules/gitlab-agent-rbac/`
- **Key variables**: `namespace`, `allowed_verbs`
- **Outputs**: `role_name`, `role_binding_name`

## Cache Platform

### hpa-deployment

Generic HPA-enabled deployment module for stateless services with object
storage backends. Used by the Attic cache API, and supports Ingress,
TLS, Prometheus scraping, and topology spread.

- **Path**: `tofu/modules/hpa-deployment/`
- **Key variables**: `name`, `namespace`, `image`, `container_port`, `enable_hpa`, `min_replicas`, `max_replicas`, `enable_ingress`
- **Outputs**: `deployment_name`, `service_endpoint`, `ingress_url`, `hpa_name`

### bazel-cache

Deploys bazel-remote cache server with S3/MinIO backend. Supports HPA
autoscaling, Ingress, and Prometheus metrics.

- **Path**: `tofu/modules/bazel-cache/`
- **Key variables**: `name`, `namespace`, `s3_endpoint`, `s3_bucket`, `s3_secret`, `max_cache_size_gb`
- **Outputs**: `service_name`, `grpc_endpoint`, `http_endpoint`, `bazelrc_config`

### postgresql-cnpg

Production-grade PostgreSQL cluster using CloudNativePG with TLS, network
policies, S3 backup, and high availability.

- **Path**: `tofu/modules/postgresql-cnpg/`
- **Key variables**: `name`, `namespace`, `database_name`, `instances`, `storage_size`, `enable_backup`
- **Outputs**: `cluster_name`, `connection_string_rw`, `database_url`, `credentials_secret_name`

## Operators

### cnpg-operator

Installs the CloudNativePG operator via Helm chart for managing PostgreSQL
cluster CRDs.

- **Path**: `tofu/modules/cnpg-operator/`
- **Key variables**: `namespace`, `chart_version`, `operator_replicas`
- **Outputs**: `namespace`, `operator_version`

### minio-operator

Installs the MinIO Operator via Helm chart for managing MinIO Tenant CRDs.

- **Path**: `tofu/modules/minio-operator/`
- **Key variables**: `namespace`, `operator_version`, `operator_replicas`
- **Outputs**: `namespace`, `operator_version`

### minio-tenant

Creates a MinIO Tenant CRD for S3-compatible object storage. Supports
standalone and distributed HA modes with lifecycle policies.

- **Path**: `tofu/modules/minio-tenant/`
- **Key variables**: `tenant_name`, `namespace`, `volume_size`, `storage_class`, `buckets`
- **Outputs**: `tenant_name`, `s3_endpoint`, `bucket_name`

## DNS

### dns-record

Reusable DNS record management supporting DreamHost API and external-dns
annotation strategies.

- **Path**: `tofu/modules/dns-record/`
- **Key variables**: `provider_type`, `domain`, `records`
- **Outputs**: `record_count`, `ingress_annotations`

## Related

- [Configuration Reference](./config-reference.md) -- organization.yaml schema
- [Pipeline Overview](../ci-cd/pipeline-overview.md) -- how modules are validated and deployed
- [Environment Variables](./environment-variables.md) -- variables consumed by stacks
