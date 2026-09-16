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

- `rundeck` (Core): authoritative location is `gradle.properties` (`<name>PluginVersion` props, e.g. `ansiblePluginVersion`). `build.gradle` interpolates them into `bundledPlugins` and `testbuild.groovy` reads them; `build.yaml` no longer carries versions. Edit the property.
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
   - Core: set `<prop>=<LATEST>` in `gradle.properties` (the `*PluginVersion` prop).
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

## Workflow C - proactive PR sweep

Use to close version drift immediately instead of just reporting it: bundles every bump a consuming repo needs into one branch/commit/PR per repo (not one PR per plugin), then opens it for human review.

```
- [ ] 1. Confirm/resolve the three repo paths
- [ ] 2. Dry run: scripts/bump-versions-pr.sh --dry-run
- [ ] 3. Run for real: scripts/bump-versions-pr.sh
- [ ] 4. Report the PR URLs opened (one per repo that needed a bump)
```

Unlike Workflows A/B, this one *does* push a branch and open a PR (not to `main` - see "Do not auto-push" below, which still applies to `main` itself). It always diffs against `origin/main`'s actual content rather than whatever happens to be checked out, and restores the original branch in each repo afterward (repos are often mid-feature-work on a ticket branch, not `main`, when this runs).

Each repo gets one stable branch (`bump-plugin-versions`, no date suffix). Re-running the script rebuilds that branch fresh off current `main` and force-pushes it every time, so it keeps **updating the same open PR in place** (via `gh pr edit`, same as Renovate's own PRs) instead of piling up a new dated branch/PR per run. If the previous PR for that branch was merged or closed, the next run starts a clean new one. Don't hand-edit the `bump-plugin-versions` branch between runs - it gets discarded and recreated.

## Workflow D - audit mapping.tsv itself

Use before trusting a "not consumed" (`-`) cell, when adding a new plugin, or after a report seems to be missing a bump you expected (that's exactly how the two real gaps below were found - the hard way, one plugin at a time, after something else already went wrong).

```
- [ ] 1. Confirm/resolve the rundeckpro and ua-runner paths
- [ ] 2. Run: scripts/audit-consumption.sh
- [ ] 3. For each POSSIBLE GAP printed, read the surrounding line in that
         file and decide: real gap (fix mapping.tsv, see reference.md's
         Gotchas for the pattern) or false positive (e.g. a comment)
```

Read-only, same spirit as `check-versions.sh`'s drift report but one level up: it checks whether the *mapping itself* is right, not whether values are current. It greps each repo's whole tracked tree (not just root `gradle.properties`/`build.gradle`) for both compact (`"group:artifact:version"`) and verbose (`group: '...', name: '...'`) Gradle dependency syntax - a plain grep for the compact form alone is exactly what missed `rundeck-ec2-nodes-plugin`'s real (verbose-syntax) dependency the first time this kind of sweep was tried by hand.

Two real gaps this would have caught immediately instead of after a missed bump (both 2026-09-16/17): 7 plugins `mapping.tsv` called vestigial/unconsumed in `rundeckpro` that were actually bundled via a real dependency list in its root `build.gradle`, and `rundeck-ec2-nodes-plugin`'s verbose-syntax dependency in `rundeckpro/plugins/cloud-aws-plugins/build.gradle`. See `reference.md`'s Gotchas section for the full list of non-obvious consumption patterns found this way.

## Release ordering across the three repos (not automated - track manually)

The three PRs Workflow C opens are **not independent releases** - there is a real cross-repo dependency chain this skill does not model or enforce, so track it by hand each cycle:

1. **rundeck (Core)**'s PR (bumps its own `gradle.properties`) should merge - and ideally Core cuts a new release - before the next step is meaningful.
2. **ua-runner**'s `rundeck/` submodule pointer needs advancing to a Core commit that includes step 1's merge. This is separate from ua-runner's own `bump-plugin-versions` PR (which only covers plugins with a real ua-runner property, e.g. `httpStepVersion`/`dockerVersion`/`vaultStorageVersion`) - advancing the submodule pointer is what actually updates `ansible-plugin`/`py-winrm-plugin`/`openssh-node-execution`/`sshj-plugin` in ua-runner (see `reference.md`'s Gotchas: these 4 are `VIA-SUBMODULE`, not a `gradle.properties` value).
3. Once both of ua-runner's changes (its own PR + the submodule advance) are merged, **ua-runner needs an actual new GitHub Release cut** - merging alone doesn't produce one.
4. **rundeckpro** consumes that ua-runner release as its own pinned `uaRunnerVersion` property in `gradle.properties` (currently `7.0.18`, separate from anything in `mapping.tsv`) - bump it once step 3 lands. rundeckpro's other 15+ direct plugin bumps in its own `bump-plugin-versions` PR are independent of this chain and don't need to wait.

**rundeckpro also has its own `rundeck/` submodule pointer, but it is not a version source the way ua-runner's is** - rundeckpro's `build.gradle` does not read plugin versions out of its submodule's `gradle.properties` (verified by grep: no `rootProject.projectDir}/rundeck` reference exists there). Don't conflate the two repos' submodule roles - only ua-runner's actually feeds plugin versions into the bundle.

## Do not auto-push

Never push directly to `main`, and never merge a PR this skill opens - a human reviews and merges. Note some consuming repos may enforce PR rulesets (direct pushes to `main` rejected). Never add Cursor/agent co-author trailers to any commit. Workflows A and B additionally stop before even opening a PR (diffs only, human opens the PR); Workflow C opens the PR itself but still leaves merging to a human.

## Gotcha: don't read gradle.properties from the working tree

`check-versions.sh` and `bump-versions-pr.sh` both snapshot `origin/main`'s `gradle.properties` via `git show origin/main:gradle.properties` rather than reading the working-tree file directly. Reading the working tree is wrong whenever a repo is checked out on an in-progress feature branch that's stale relative to `main` (common - these are active repos) - it can report false drift, miss real drift, or (as happened once for real) make a proactive PR's commit message claim more changes than actually happened. Keep this pattern if you're modifying either script.

## Gotcha: a brand-new property must be appended, not silently dropped

`bump-versions-pr.sh` always rebuilds the `bump-plugin-versions` branch fresh off current `main` (see Workflow C) - by design, so re-runs never accumulate stale hand-edits. That design has a sharp edge: if a property was added by hand directly to an open `bump-plugin-versions` PR branch (not yet merged to `main`), the *next* run discards that branch and recreates it from `main`, which never had the line - and the old bump loop only knew how to `sed`-substitute an *existing* line, so it silently produced no output for a property that didn't exist yet. Found for real 2026-09-17: 4 properties (`ansiblePluginVersion`, `pyWinrmPluginVersion`, `opensshNodeExecutionVersion`, `sshjPluginVersion`) hand-added to `ua-runner`'s PR #222 vanished on the very next real run of the script. Fixed: the bump-computation loop now distinguishes "property exists but is stale" from "mapping.tsv tracks this property for this repo but the file has no such line at all," and the edit loop appends a new `prop=value` line (at EOF) for the latter instead of running a no-op `sed`. Keep this distinction if you touch either loop - don't collapse it back into a single "skip if empty" check.

## Gotcha: a missing property must not crash the whole script

Both scripts' `prop_ver()` ends in a `grep | head | sed` pipeline. Under this repo's `set -euo pipefail`, `grep` finding no match (a property that's genuinely not there yet - e.g. added to `mapping.tsv` but the PR adding the actual property line hasn't merged) exits 1, and with `pipefail` that becomes the whole pipeline's exit status - which kills the *entire script* silently (no error message, just stops) when it happens inside a plain `var=$(...)` assignment, rather than being treated as the normal "not found" case it actually is. Found for real 2026-09-17: checking `ansible-plugin` right after adding it to `ua-runner`'s `mapping.tsv` column, before the PR adding the property had merged, silently killed `check-versions.sh` with zero output. Both copies of `prop_ver()` now end the pipeline with `|| true` - keep that if you touch either one.

## Scripts

- `scripts/plugin-latest.sh <plugin-repo>` - latest released version (gh release, clean-semver tag fallback).
- `scripts/check-versions.sh [--root DIR | --rundeck DIR --rundeckpro DIR --ua-runner DIR] [--plugin NAME]` - read-only drift report across the three repos.
- `scripts/bump-versions-pr.sh [--root DIR | --rundeck DIR --rundeckpro DIR --ua-runner DIR] [--dry-run]` - opens one PR per repo bundling every bump it needs.
- `scripts/audit-consumption.sh [--root DIR | --rundeckpro DIR --ua-runner DIR]` - read-only check that every `-` cell in `mapping.tsv` is actually right; see Workflow D.
