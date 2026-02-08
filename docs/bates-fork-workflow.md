# Bates Fork Workflow

**Internal Documentation** - How Bates ILS maintains attic-cache as a fork of the upstream repository.

## Overview

The Bates attic-cache repository is maintained as a fork of the public upstream at `github.com/Jesssullivan/attic-iac`. This allows us to:

1. **Pull upstream improvements** - Get bug fixes, new features, and documentation updates
2. **Contribute back** - Share generic improvements with the community
3. **Maintain Bates-specific configs** - Keep our organization details private

## Repository Structure

### Upstream (Public): `github.com/Jesssullivan/attic-iac`

**Contains**:

- All OpenTofu modules (generic)
- All stacks (generic)
- Runner dashboard app (generic)
- Documentation (generic examples)
- `config/organization.example.yaml` (template)
- CI/CD templates

**Does NOT contain**:

- Bates-specific organization.yaml
- Bates tfvars files
- Bates network configs
- Internal runbooks

### Bates Fork (Private): `gitlab.com/bates-ils/people/jsullivan2/attic-cache`

**Contains everything from upstream PLUS**:

- `config/organization.yaml` (gitignored - Bates-specific)
- `tofu/stacks/*/beehive.tfvars` (Bates dev cluster)
- `tofu/stacks/*/rigel.tfvars` (Bates prod cluster)
- Internal documentation
- Bates-specific CI/CD configurations
- `.env` (secrets, gitignored)

## Branch Strategy

### Main Branches

- `main` - Stable, deployed to production (rigel)
- `dev` - Development, deployed to beehive
- `upstream/main` - Tracks upstream repository

### Feature Branches

- `feat/*` - New features (may contribute back)
- `fix/*` - Bug fixes (may contribute back)
- `bates/*` - Bates-specific changes (do NOT contribute back)
- `sid/*` - Personal feature branches

## Pulling Upstream Changes

### Setup Upstream Remote (One-time)

```bash
# Add upstream as a remote
git remote add upstream https://github.com/Jesssullivan/attic-iac.git

# Verify remotes
git remote -v
# Should show:
#   origin    git@gitlab-work:bates-ils/people/jsullivan2/attic-cache.git (push/fetch)
#   upstream  https://github.com/Jesssullivan/attic-iac.git (fetch)
```

### Regular Upstream Sync

**Weekly or as needed**:

```bash
# Fetch upstream changes
git fetch upstream

# Review what's new
git log main..upstream/main --oneline

# Merge upstream into your branch
git checkout dev
git merge upstream/main

# Resolve any conflicts (see below)
# Test thoroughly
git push origin dev
```

### Resolving Conflicts

Common conflict scenarios:

#### 1. Organization Config Conflicts

**Conflict**: Upstream changed `organization.example.yaml`

**Resolution**: Keep both - upstream example is public template, ours is private

```bash
# Accept upstream changes to the example
git checkout upstream/main -- config/organization.example.yaml

# Our config/organization.yaml is gitignored, so no conflict there
```

#### 2. Documentation Conflicts

**Conflict**: Both updated README.md or docs

**Resolution**: Merge carefully, keep Bates-specific notes in separate files

```bash
# Manually merge, preferring upstream's generic content
# Move Bates-specific content to docs/bates-*.md if needed
```

#### 3. Module Conflicts

**Conflict**: Both modified a module

**Resolution**: Prefer upstream unless Bates has critical fix

```bash
# If upstream is better:
git checkout upstream/main -- tofu/modules/module-name/

# If Bates fix is critical:
# 1. Keep Bates version
# 2. Create PR to contribute back to upstream
# 3. After upstream accepts, pull it back
```

## Contributing Back to Upstream

### When to Contribute

✅ **DO contribute**:

- Generic bug fixes
- New modules that others could use
- Documentation improvements
- Test improvements
- CI/CD enhancements (generic parts)

❌ **DO NOT contribute**:

- Bates-specific configs (organization.yaml, \*.tfvars)
- Internal network details (SOCKS proxy, bastion hosts)
- Bates runbooks or procedures
- Anything with "bates", "beehive", "rigel" hardcoded

### Contribution Process

1. **Create clean feature branch from upstream**:

   ```bash
   git fetch upstream
   git checkout -b contrib/your-feature upstream/main
   ```

2. **Make generic changes**:

   - Remove any Bates-specific references
   - Use placeholder examples (example.com, myorg, etc.)
   - Test with organization.example.yaml

3. **Test thoroughly**:

   ```bash
   just check
   tofu validate
   ```

4. **Push to your GitHub fork**:

   ```bash
   # If you don't have a GitHub fork yet:
   # Fork github.com/Jesssullivan/attic-iac on GitHub

   git remote add github git@github.com:YOUR-USERNAME/attic-iac.git
   git push github contrib/your-feature
   ```

5. **Create Pull Request**:

   - Go to https://github.com/Jesssullivan/attic-iac
   - Click "New Pull Request"
   - Select your fork and branch
   - Describe the change and why it's useful

6. **After merge, sync back**:
   ```bash
   git fetch upstream
   git checkout dev
   git merge upstream/main
   ```

## Maintaining Bates-Specific Files

### Files to NEVER commit to upstream:

```
config/organization.yaml          # Bates identity
tofu/stacks/*/beehive.tfvars     # Bates dev config
tofu/stacks/*/rigel.tfvars       # Bates prod config
.env                              # Secrets
docs/bates-*.md                   # Internal docs
```

These are either:

1. Gitignored (organization.yaml, .env)
2. Documented to NOT be in upstream

### Bates-Specific Documentation

Keep in separate files prefixed with `bates-`:

- `docs/bates-fork-workflow.md` (this file)
- `docs/bates-runbook.md` (if needed)
- `docs/bates-network-setup.md` (if needed)

## Testing Upstream Changes Locally

Before merging upstream changes:

```bash
# Create test branch
git checkout -b test/upstream-sync upstream/main

# Use Bates config
# (organization.yaml is gitignored, so it's still there)

# Test with Bates tfvars
ENV=beehive just tofu-plan attic

# If plan looks good:
git checkout dev
git merge upstream/main
```

## Rollback Strategy

If upstream merge causes issues:

```bash
# Find commit before merge
git log --oneline -10

# Reset to before merge
git reset --hard <commit-before-merge>

# Force push (ONLY on dev branch, NEVER on main)
git push origin dev --force-with-lease
```

## Automated Sync (Future)

Consider setting up a GitLab CI job to:

1. Weekly check for upstream changes
2. Create MR to merge upstream/main
3. Run tests automatically
4. Notify team for review

Example `.gitlab-ci.yml` job:

```yaml
upstream-sync-check:
  stage: sync
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  script:
    - git fetch upstream
    - git checkout -b auto-sync/$(date +%Y%m%d) origin/dev
    - git merge upstream/main --no-commit
    - ENV=beehive just tofu-plan attic
  artifacts:
    paths:
      - plan.tfplan
  allow_failure: true
```

## Troubleshooting

### Conflict: "both modified: config/organization.example.yaml"

```bash
# Accept upstream's version (it's the public template)
git checkout upstream/main -- config/organization.example.yaml
git add config/organization.example.yaml
```

### Conflict: Module changes

```bash
# See what changed
git diff upstream/main...HEAD -- tofu/modules/problematic-module/

# Decision tree:
# - If upstream is better: git checkout upstream/main -- path/to/module/
# - If Bates has fix: keep ours, plan to contribute back
# - If both have good changes: manual merge
```

### Lost Bates configs

```bash
# config/organization.yaml should be gitignored
git status --ignored

# If accidentally deleted:
git checkout HEAD -- config/organization.yaml

# If not in git (gitignored), restore from backup or recreate from example
```

## Team Responsibilities

### Infrastructure Team

- Weekly upstream sync review
- Test upstream changes in beehive before merging to main
- Maintain Bates-specific configs
- Contribute generic improvements back

### Developers Using the Stack

- Report bugs (check if upstream or Bates-specific)
- Suggest improvements (indicate if upstream-worthy)
- Test new runner types or features

## Questions?

- **Upstream issues**: Open issue at https://github.com/Jesssullivan/attic-iac/issues
- **Bates-specific**: Slack #infrastructure or email jsullivan2@bates.edu
- **Unsure if upstream or Bates**: Ask in #infrastructure first

---

**Last Updated**: 2026-02-08
**Maintained By**: Jess Sullivan (ILS Infrastructure)
