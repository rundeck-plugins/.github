# Organization Infrastructure Repository

This repository is the starting point for working across the `rundeck-plugins` organization. It holds the org-wide engineering guide for AI agents and humans, shared security scanning infrastructure, and bulk-operation scripts.

## Getting Started

Start here, whether you're a contributor or pointing an AI agent at the org:

1. **Read the engineering guide.** [`CLAUDE.md`](CLAUDE.md) is the canonical guide: working agreements, build/release and branch conventions, security scanning, and environment notes. [`AGENTS.md`](AGENTS.md) mirrors it. Plugin inventory and per-plugin specifics are in [`PLUGINS_OVERVIEW.md`](PLUGINS_OVERVIEW.md).
2. **Set up a local workspace.** Create a container folder and clone the repos into it (the folder itself is just a container, not a git repo):

   ```bash
   mkdir -p ~/Documents/GitHub/rundeck-plugins && cd ~/Documents/GitHub/rundeck-plugins
   git clone https://github.com/rundeck-plugins/.github.git
   # Clone all active (non-archived) repos in parallel:
   gh repo list rundeck-plugins --no-archived --limit 200 --json name -q '.[].name' \
     | xargs -P4 -I{} gh repo clone rundeck-plugins/{}
   ```

3. **Let the per-repo instructions do the work.** Every active repo has a generated `.github/copilot-instructions.md` that points back to this guide and inlines the essentials, so Copilot/Cursor/Claude follow the same conventions in any repo. Don't hand-edit those files; edit [`templates/copilot-instructions.shared.md`](templates/copilot-instructions.shared.md) and re-run the sync script.
4. **Use the bulk-ops scripts** in [`scripts/`](scripts) for multi-repo work:
   - `scripts/org-sync.sh status` - read-only branch / dirty / ahead-behind report across all clones.
   - `scripts/org-sync.sh sync --discard` - re-point every clone to its default branch (discards local changes).
   - `scripts/sync-copilot-instructions.sh` - stamp the shared Copilot template into each repo (`--check` to report drift only).
5. **Use the shared Agent Skills** in [`skills/`](skills) for repeatable workflows:
   - [`skills/rundeck-plugin-versions`](skills/rundeck-plugin-versions) - bump a released plugin's version across `rundeck`, `rundeckpro`, and `ua-runner`, or run a pre-release drift sweep. Install with `cp -R skills/rundeck-plugin-versions ~/.cursor/skills/`.

Default branch for all active repos is `main`.

## Purpose

The primary goal is centralized Snyk security scanning across all plugin repositories. This ensures consistent security standards and simplifies maintenance.

## Files

- **`.github/workflows/snyk-scan-reusable.yml`** - Central reusable workflow for security scanning
- **`snyk-scan.yml`** - Minimal template for implementing security scans  
- **`calling-workflow-example.yml`** - Full configuration example with comments
- **`snyk-scan-info.md`** - Complete setup documentation and troubleshooting
- **`profile/README.md`** - Organization profile page content

## Snyk Scanning

### Documentation

See [snyk-scan-info.md](snyk-scan-info.md) for detailed setup instructions and configuration options.

### Quick Setup

For repository maintainers:

1. Copy `snyk-scan.yml` to your repository as `.github/workflows/security-scan.yml`
2. Commit and push
3. Security scans run automatically on pushes and pull requests

No additional configuration is required. All parameters are optional with sensible defaults.

### Features

- Automatic detection of main/master branches
- Pre-configured organization secrets
- Blocking security tests (workflow fails on high-severity vulnerabilities)
- Results integrated with Snyk dashboard
- Support for Java 8, 11, 17, and 21 (default: 17)

### Benefits

- Single point of maintenance for security scanning logic
- Consistent security standards across all repositories
- Easy updates to scanning procedures organization-wide
- Simplified onboarding for new repositories