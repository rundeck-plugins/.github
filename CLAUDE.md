# rundeck-plugins Org Engineering Guide

Canonical, org-wide working guide for AI coding agents (Claude, Cursor, Copilot) and humans working across the `rundeck-plugins` GitHub organization.

- This file (`CLAUDE.md`) is the single source of truth.
- `AGENTS.md` in this repo mirrors it (it points back here) for tools that prefer that filename.
- Each plugin repo carries a generated `.github/copilot-instructions.md` that links here and inlines the shared essentials (see `templates/copilot-instructions.shared.md`).
- The local multi-repo workspace `.cursorrules` is a thin pointer to this file.
- Plugin inventory, types, and per-plugin specifics live in [`PLUGINS_OVERVIEW.md`](PLUGINS_OVERVIEW.md).

---

## 1. Organization layout

The `rundeck-plugins` org hosts the open-source plugins used by Rundeck. Local development is typically done from a container directory that holds one clone per repo:

```
rundeck-plugins/            # container folder (NOT a git repo)
├── .github/                # THIS repo: org-wide infra, agent guides, Snyk workflows
├── ansible-plugin/         # one clone per plugin repo
├── docker/
├── kubernetes/
└── ...                     # ~37 active repos
```

- The `.github` repo is special: GitHub uses it for org-wide defaults (profile, shared workflows). We also use it as the home for these agent guides and bulk-ops scripts.
- The container folder itself is not version controlled. Anything that must be shared belongs in a real repo (usually this one).

## 2. Who you are working with

You are working with Forrest, a technical product manager (not a full-time engineer). Provide the technical detail, but always connect it to customer and business impact.

Every technical decision is filtered through:
- Customer impact first - what breaks for paying customers?
- Business reality - if customers can't use it, we can't ship it.
- Practical over perfect - working for customers beats architectural purity.

If Forrest says "look at the bigger picture" or "avoid symptom chasing," stop: you skipped architecture. Re-read the relevant docs, explain the system, or ask questions, then continue.

## 3. Product team mantras

- We strive for backwards compatibility.
- Champion the customer.
- We announce deprecations, but don't remove until the next major version.
- We do it right or we don't do it.

## 4. Decision-making authority

You lead on: technical exploration, solution implementation, pattern recognition, documentation.

Forrest decides on: product direction, customer-impact trade-offs (breaking changes, deprecations), when to ship, when to pivot.

You propose, Forrest chooses.

## 5. Working agreements

- Git pushes: work locally; do not push to GitHub unless asked. Forrest pushes at end of day or major stopping points.
- Commits: only commit when explicitly asked. Never add `Co-authored-by: Cursor` or any Cursor/agent references, author flags, or email trailers. Plain messages describing the change only.
- Commit messages and PR descriptions: capture the "why" and the customer impact, not just the "what."
- Emojis: avoid them in updates and files unless explicitly requested.
- Status updates: keep working rather than stopping frequently; ask when genuinely stuck or when a decision is Forrest's to make.
- Build logs: write full build output to a `temp/` directory at the repo root (create if missing), using `YYYYMMDD-HHMMSS-<desc>.log` filenames. Re-read the saved log instead of re-running builds with different greps.
- Communication is direct and correction-heavy. "No, that's wrong" means course-correct and continue.

## 6. Build and release conventions

Baseline is Rundeck 6.0 (Grails 7 / Spring Boot 3 / Java 17). The Grails 7 + PackageCloud migration is complete; treat the following as the steady state.

- Java: JAR plugins build on Java 17.
- Maven coordinates: group `com.rundeck.plugins`, artifact `<plugin-name>`.
- Versioning: Axion from git tags with `prefix = ''` (no `v` prefix). Tags look like `1.2.3`. Branch-name suffixing is disabled (`branchVersionCreator` maps `main` and `master` to `simple`).
- Two plugin types:
  - JAR plugins: compiled Java/Groovy depending on `rundeck-core`.
  - ZIP plugins: script-based, but MUST be packaged with Gradle `type: Jar` (archiveExtension `zip`), published with `extension = 'jar'` and `pom.packaging = 'jar'` for Maven repo compatibility. Process `plugin.yaml` tokens with `ReplaceTokens` (never `expand`, which clobbers runtime `${...}` placeholders).
- Multi-module: `nixy-step-plugins` shares one root version across 4 independently published submodules (waitfor, file, local-script, command).

See [`PLUGINS_OVERVIEW.md`](PLUGINS_OVERVIEW.md) for per-plugin type, coordinates, and gotchas.

## 7. Branch conventions

- Default branch is `main` for all active repos (standardized; legacy `master` was renamed org-wide).
- `snyk-weekly` is an automation branch from the shared scanning workflow; it is not a working branch.
- Feature work uses ticket-prefixed branches (e.g. `RUN-1234-short-desc`).
- CI triggers should target `main`. The shared Snyk workflow tolerates both `main` and `master`, but new/maintained triggers should use `main`.

## 8. Security scanning (Snyk)

Security scanning is centralized in this repo:
- Reusable workflow: `.github/workflows/snyk-scan-reusable.yml`.
- Per-repo caller: `snyk-scan.yml` (copied into each repo as `.github/workflows/`), runs on push/PR to `main`/`master`, weekly Monday 06:00 UTC, and `workflow_dispatch`.
- Monitor (dashboard) runs only on the default branch; feature branches test but do not send data.
- Setup and troubleshooting: `snyk-scan-info.md`.

## 9. Local environment notes (Forrest's machine)

- `.zshrc` aliases switch between Java 11 and Java 17. Rundeck 6.0 / Grails 7 work needs 17.
- Java tests that spin up Docker containers must be run by Forrest (keyring auth prompts); the agent cannot run them.
- Raw Rundeck docs: `~/Documents/GitHub/docs/docs`. Main architecture docs: `~/Documents/GitHub/rundeckpro/architecture` (start with its `README.md`).

## 10. Bulk org operations

Helper scripts live in `scripts/` in this repo:
- `org-sync.sh` - sync every clone to its default branch (with a read-only `status` mode).
- `sync-copilot-instructions.sh` - stamp `templates/copilot-instructions.shared.md` into each repo's `.github/copilot-instructions.md`.

When checking the current date, do not assume the training cutoff; check the actual system date.
