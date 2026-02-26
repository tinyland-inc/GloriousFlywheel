---
title: Cross-Forge CI
order: 2
---

# Cross-Forge CI

GloriousFlywheel supports both GitLab CI and GitHub Actions from the same
Kubernetes cluster. This guide shows equivalent configurations side by side.

## Quick Comparison

| Feature | GitLab CI | GitHub Actions |
|---------|-----------|----------------|
| Config file | `.gitlab-ci.yml` | `.github/workflows/*.yml` |
| Runner selection | `tags: [docker]` | `runs-on: tinyland-docker` |
| Scaling | HPA (always-warm) | ARC (scale-to-zero) |
| Cache access | Auto-injected env vars | Auto-injected env vars |
| Reusable configs | CI/CD Components | Composite Actions |
| CLI tool | `glab` | `gh` |

## Equivalent Jobs

### Simple Build

**GitLab CI:**

```yaml
build:
  tags: [docker]
  script:
    - make build
```

**GitHub Actions:**

```yaml
jobs:
  build:
    runs-on: tinyland-docker
    steps:
      - uses: actions/checkout@v4
      - run: make build
```

### Nix Build with Cache

**GitLab CI:**

```yaml
build:
  tags: [nix]
  script:
    - nix build .#default
    - attic push main result
```

**GitHub Actions:**

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

### Docker Image Build

**GitLab CI:**

```yaml
build-image:
  tags: [dind]
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

**GitHub Actions:**

```yaml
jobs:
  build-image:
    runs-on: tinyland-dind
    steps:
      - uses: actions/checkout@v4
      - run: |
          docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
```

## CLI Commands

### Pipeline / Workflow Status

```bash
# GitLab
glab ci status
glab ci view

# GitHub
gh run list
gh run view <run-id>
```

### Create Merge Request / Pull Request

```bash
# GitLab
glab mr create --fill --squash-before-merge

# GitHub
gh pr create --fill
```

### View CI Logs

```bash
# GitLab
glab ci trace

# GitHub
gh run view <run-id> --log
```

## When to Use Which Forge

| Scenario | Recommended Forge | Reason |
|----------|-------------------|--------|
| IaC changes (this repo) | GitLab | State backend on GitLab, CI/CD Components |
| Open source projects | GitHub | Community visibility, Actions marketplace |
| Private org projects | Either | Both have full runner access |
| Nix builds | Either | Both use the same Attic cache |

## See Also

- [GitHub App Adoption](github-app-adoption.md) -- install GloriousFlywheel on your org
- [Self-Service Enrollment](../runners/self-service-enrollment.md) -- GitLab runner enrollment
- [GitHub Actions Runners](../runners/github-actions.md) -- ARC runner details
