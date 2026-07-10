---
name: rundeck-plugin-versions
description: >-
  Checks and updates rundeck-plugins plugin versions across the rundeck,
  rundeckpro, and ua-runner repositories using GitHub Releases as the source of
  truth. Use when bumping a plugin to a newly released version in the consuming
  repos, or running a pre-release sweep to find and fix plugin version drift.
---

# Rundeck Plugin Versions

Update a released plugin's version in the correct place(s) across the three consuming repos, and detect version drift before a Rundeck product release.

## Install (canonical source lives in the org .github repo)

This skill is versioned in `rundeck-plugins/.github/skills/rundeck-plugin-versions/`. Because the work spans repos outside any single workspace, install it as a personal skill so it is available everywhere:

```bash
cp -R /path/to/.github/skills/rundeck-plugin-versions ~/.cursor/skills/
```

Re-copy to pick up updates. Keep the canonical copy in the `.github` repo authoritative.

## Prerequisites

- `gh` authenticated (`gh auth status`) with access to the `rundeck-plugins` org.
- The three consuming repos cloned locally: `rundeck`, `rundeckpro`, `ua-runner`.
- Do not push or open PRs automatically; leave that to the human (see below).

## Repo path discovery

The three repos live outside the plugins workspace and paths vary per user. Default assumption: they are siblings under one parent (e.g. `~/Documents/GitHub/{rundeck,rundeckpro,ua-runner}`). If any path is missing, ask the user or pass explicit paths:

```bash
scripts/check-versions.sh --root /some/dir
# or
scripts/check-versions.sh --rundeck DIR --rundeckpro DIR --ua-runner DIR
```

## Source of truth

- Latest released version = GitHub Releases: `scripts/plugin-latest.sh <plugin-repo>`.
- Do NOT trust local git tags (they include legacy `v`-prefixed and `-grails7`/`-test` tags).
- The plugin -> version-location mapping is [`mapping.tsv`](mapping.tsv); rules and gotchas are in [`reference.md`](reference.md). Always consult it - property names do not match repo names and differ between repos.

## Edit rules (critical)

- `rundeck` (Core): authoritative location is `build.yaml` (`org.rundeck.plugins:<artifact>:<version>`). The matching `gradle.properties` props are vestigial; update `build.yaml`.
- `rundeckpro` and `ua-runner`: edit the property in `gradle.properties`.
- `kubernetes` uses `kubernetesVersion` in rundeckpro but `kubernetesPluginVersion` in ua-runner.
- `nixy-step-plugins`: one release drives `nixystepVersion` (four artifacts share it).
- Only touch the specific plugin's line(s); never reformat surrounding properties.

## Workflow A - bump one plugin

Use when a single plugin has published a new release.

```
- [ ] 1. Confirm/resolve the three repo paths
- [ ] 2. In each repo: git fetch, checkout main, git pull
- [ ] 3. Get latest release: scripts/plugin-latest.sh <plugin-repo>
- [ ] 4. Look up the plugin in mapping.tsv / reference.md
- [ ] 5. For each affected repo: create a branch, update the location(s)
- [ ] 6. Show per-repo diffs and a summary; STOP (no push)
```

Details:
1. Verify paths exist (see discovery above).
2. Sync each affected repo to latest `main` so edits land on current code.
3. `LATEST=$(scripts/plugin-latest.sh ansible-plugin)`.
4. From `mapping.tsv`, determine which repos/locations reference the plugin.
5. Branch name suggestion: `bump-<plugin>-<version>`. Edit:
   - Core: replace the version in the `org.rundeck.plugins:<artifact>:<old>` line of `build.yaml`.
   - rundeckpro/ua-runner: set `<prop>=<LATEST>` in `gradle.properties`.
6. Print `git diff` per repo and a summary table. Do not commit-push; the human reviews and opens PRs.

## Workflow B - pre-release sweep

Use just before a Rundeck product release to ensure every plugin is at its latest released version.

```
- [ ] 1. Confirm/resolve the three repo paths
- [ ] 2. In each repo: git fetch, checkout main, git pull
- [ ] 3. Run the drift report: scripts/check-versions.sh
- [ ] 4. For each DRIFT row, apply Workflow A steps 5-6
- [ ] 5. Summarize what changed; STOP (no push)
```

The report marks any value that differs from the latest release with `*` and prints a per-plugin `OK` / `DRIFT` / `UNKNOWN` status; it exits non-zero if any drift exists (useful as a release gate). `check-versions.sh` is read-only.

## Do not auto-push

Make edits on branches and report diffs only. The user opens PRs. Note some consuming repos may enforce PR rulesets (direct pushes to `main` rejected). Never add Cursor/agent co-author trailers to any commit.

## Scripts

- `scripts/plugin-latest.sh <plugin-repo>` - latest released version (gh release, clean-semver tag fallback).
- `scripts/check-versions.sh [--root DIR | --rundeck DIR --rundeckpro DIR --ua-runner DIR] [--plugin NAME]` - read-only drift report across the three repos.
