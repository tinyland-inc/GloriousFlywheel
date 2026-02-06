# Nix Builds with Attic Cache

Guide for using the Nix runner with Attic binary cache integration.

## Overview

The `bates-nix` runner provides:

- Nix with flakes enabled
- Integration with Attic binary cache
- 20Gi ephemeral Nix store per job
- Automatic experimental features enabled

## Quick Start

```yaml
nix-build:
  tags:
    - nix
    - flakes
  script:
    - nix build .#default
    - nix flake check
```

## Attic Cache Integration

The Nix runner is pre-configured with the Attic cache at `https://attic-cache.beehive.bates.edu`.

### Environment Variables

Available in all Nix jobs:

- `ATTIC_SERVER`: `https://attic-cache.beehive.bates.edu`
- `ATTIC_CACHE`: `main`
- `NIX_CONFIG`: `experimental-features = nix-command flakes`

### Pushing to Cache

To push build results to the cache, you need the `ATTIC_TOKEN` variable:

```yaml
nix-build-and-cache:
  tags:
    - nix
  variables:
    ATTIC_TOKEN: $ATTIC_TOKEN # Set in GitLab CI/CD variables
  script:
    - nix build .#default
    # Configure attic
    - attic login bates $ATTIC_SERVER $ATTIC_TOKEN
    - attic use main
    # Push result to cache
    - attic push main result
```

### Setting Up ATTIC_TOKEN

1. Go to your project's **Settings > CI/CD > Variables**
2. Add `ATTIC_TOKEN` with:
   - Value: Your Attic token
   - Type: Variable
   - Protect variable: Yes (recommended)
   - Mask variable: Yes

## Common Workflows

### Build and Test

```yaml
stages:
  - build
  - test

build:
  stage: build
  tags:
    - nix
  script:
    - nix build .#default
  artifacts:
    paths:
      - result

test:
  stage: test
  tags:
    - nix
  script:
    - nix flake check
```

### Build Multiple Packages

```yaml
build-all:
  tags:
    - nix
  script:
    - nix build .#package1
    - nix build .#package2
    - nix build .#all # Or use a combined output
```

### Development Shell Testing

```yaml
test-devshell:
  tags:
    - nix
  script:
    - nix develop -c bash -c "echo 'Dev shell works'"
    - nix develop -c make test
```

### Cross-Compilation

```yaml
cross-compile:
  tags:
    - nix
  script:
    - nix build .#packages.aarch64-linux.default
```

### OCI Container Build

```yaml
build-container:
  tags:
    - nix
  script:
    - nix build .#container
    # Load into docker if needed
    - docker load < result
```

## Flake Templates

### Basic flake.nix

```nix
{
  description = "My project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.hello;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.hello ];
        };

        checks.default = self.packages.${system}.default;
      });
}
```

### With Attic Cache Configuration

Add to your `flake.nix`:

```nix
{
  nixConfig = {
    extra-substituters = [
      "https://attic-cache.beehive.bates.edu/main"
    ];
    extra-trusted-public-keys = [
      "main:YOUR_PUBLIC_KEY_HERE"
    ];
  };

  # ... rest of flake
}
```

## Caching Strategies

### Greedy Push (Recommended)

Push everything that was built:

```yaml
build-and-cache:
  tags:
    - nix
  script:
    - nix build .#default
    - attic push main result -j 4 # Parallel upload
```

### Selective Push

Push only specific outputs:

```yaml
build-and-cache:
  tags:
    - nix
  script:
    - nix build .#mypackage
    - attic push main ./result
    # Don't push development dependencies
```

### Pre-warm Cache

For large projects, pre-warm the cache:

```yaml
warm-cache:
  tags:
    - nix
  only:
    - schedules
  script:
    - nix build .#default --dry-run 2>&1 | grep "will be built" && \
      nix build .#default && attic push main result || \
      echo "Cache is warm"
```

## Performance Tips

### 1. Use Nix Sandbox

Ensure builds are reproducible:

```yaml
build:
  tags:
    - nix
  script:
    - nix build .#default --sandbox
```

### 2. Limit Parallelism for Memory

```yaml
build-large:
  tags:
    - nix
  variables:
    NIX_BUILD_CORES: "2"
  script:
    - nix build .#large-package
```

### 3. Garbage Collection

Clean up before large builds:

```yaml
build:
  tags:
    - nix
  before_script:
    - nix-collect-garbage
  script:
    - nix build .#default
```

### 4. Flake Lock Updates

Cache the lock file:

```yaml
build:
  tags:
    - nix
  cache:
    key: flake-lock-$CI_COMMIT_REF_SLUG
    paths:
      - flake.lock
  script:
    - nix build .#default
```

## Troubleshooting

### "experimental Nix feature 'flakes' is disabled"

Ensure you're using the correct tags:

```yaml
tags:
  - nix
  - flakes
```

### Slow builds (no cache hits)

1. Check Attic configuration:

   ```yaml
   script:
     - echo "Server: $ATTIC_SERVER"
     - echo "Cache: $ATTIC_CACHE"
   ```

2. Verify substituters are configured:
   ```yaml
   script:
     - nix show-config | grep substituters
   ```

### Out of disk space

The Nix store has a 20Gi limit. For large builds:

1. Clean garbage first:

   ```yaml
   before_script:
     - nix-collect-garbage -d
   ```

2. Request larger store (contact admin)

### "cannot build on remote"

The Nix runner doesn't use remote builders. All builds are local. For distributed builds, consider Hydra.

## Example: Full CI/CD Pipeline

```yaml
stages:
  - check
  - build
  - test
  - deploy

variables:
  ATTIC_TOKEN: $ATTIC_TOKEN

.nix-job:
  tags:
    - nix
    - flakes

lint:
  extends: .nix-job
  stage: check
  script:
    - nix flake check

build:
  extends: .nix-job
  stage: build
  script:
    - nix build .#default
    - attic push main result
  artifacts:
    paths:
      - result

test:
  extends: .nix-job
  stage: test
  script:
    - nix develop -c make test

deploy:
  extends: .nix-job
  stage: deploy
  only:
    - main
  script:
    - nix build .#deploy-script
    - ./result/bin/deploy
```
