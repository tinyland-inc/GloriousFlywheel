# Project Onboarding Guide

Step-by-step guide for enrolling a GitLab project on the shared HPA runner pool.

## Prerequisites

1. **Project location**: Your project must be in a group where runners are registered.
   Runners only propagate *downward* in the GitLab group hierarchy. If your project
   is in a sibling subgroup, you need additional runner registrations scoped to your
   group (see [Bates-specific enrollment](https://gitlab.com/bates-ils/people/jsullivan2/attic-cache/-/blob/main/docs/bates-runner-enrollment.md) for an example).

2. **CI variables**: Nix jobs require `ATTIC_TOKEN` (masked, protected) for cache access.
   Deployment jobs may need `CI_SSH_PRIVATE_KEY` and environment-specific variables.

3. **Runner visibility**: Verify runners appear in your project under
   **Settings > CI/CD > Runners**. If they don't, the runner group scope needs updating.

## Step 1: Choose Runners

Use the [Runner Selection Guide](runner-selection.md) to map each CI job to a runner type:

| Workload | Runner | Tag |
|----------|--------|-----|
| Python lint/test | docker | `docker` |
| Nix flake builds | nix | `nix` |
| Container image builds | dind | `dind` |
| RHEL 8 packaging | rocky8 | `rocky8` |
| RHEL 9 packaging | rocky9 | `rocky9` |

## Step 2: Add Tags to Jobs

Add `tags:` to each job in your `.gitlab-ci.yml`:

**Before:**
```yaml
lint:python:
  stage: validate
  image: python:3.11-slim
  script:
    - ruff check src/
```

**After:**
```yaml
lint:python:
  stage: validate
  tags: [docker]
  image: python:3.11-slim
  script:
    - ruff check src/
```

Jobs without `tags:` continue running on GitLab SaaS shared runners.

## Step 3: Configure Cache (Nix Jobs)

Nix runners inject `ATTIC_SERVER` and `ATTIC_CACHE` environment variables for the
cluster-local Attic cache. If your project uses its own Attic cache, set these
variables at the job level — job-level variables override runner-injected values:

```yaml
build:nix:
  tags: [nix]
  extends: .nix-attic
  variables:
    ATTIC_SERVER: "https://your-cache.example.com"
    ATTIC_CACHE: "your-cache-name"
```

## Step 4: Verify Pipeline

1. Push your branch and check the pipeline
2. Click on a tagged job — the runner name should show `bates-docker`, `bates-nix`, etc.
3. Check job duration against baseline (SaaS runner times)
4. For Nix jobs, verify cache hits in the build log

## Worked Example: upgrading-dw

The `upgrading-dw` project migrated all CI jobs to dedicated runners:

| Job | Runner Tag | Notes |
|-----|-----------|-------|
| lint:python, typecheck:python, test:python | `docker` | Fast Python jobs |
| test:e2e, test:integration | `docker` | Pipeline validation |
| lint:ansible, test:smoke-configs | `docker` | Ansible validation |
| test:molecule | `dind` | Needs Docker-in-Docker |
| validate-docs, test-docs, pages | `docker` | MkDocs builds |
| validate:nix-flake, check:orchestrator-nix | `nix` | Flake validation |
| check:haskell-format, lint:haskell | `nix` | Haskell code quality |
| test:haskell-quickcheck | `nix` | Property tests |
| build:orchestrator-nix, build:orchestrator-nix-release | `nix` | Haskell builds |
| build:orchestrator-nix-static, build:orchestrator-nix-musl-upx | `nix` | MUSL static builds |
| build:orchestrator (buildah fallback) | `dind` | Container builds |
| package:fpm:el8 | `rocky8` | EL8 RPM packaging |
| package:fpm:el9 | `rocky9` | EL9 RPM packaging |
| deploy:repo | `mgr` | PVE node (unchanged) |
| deploy:dev | `docker` | SSH-based deployment |

The project keeps its own Attic cache (`nix-cache.fuzzy-dev.tinyland.dev / dw-cache`)
via job-level `ATTIC_SERVER` / `ATTIC_CACHE` variables that override the runner defaults.
