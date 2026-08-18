#!/usr/bin/env bash
#
# sync-code-review-skill.sh
#
# Stamp the shared Copilot code-review skill into each active repo's
# .github/skills/code-review/SKILL.md. GitHub Copilot code review looks
# for a skill directory named exactly "code-review" and picks it up
# automatically for pull request reviews (see: "Adding agent skills for
# GitHub Copilot" in the GitHub Copilot docs).
#
# The template already carries its own frontmatter and a DO-NOT-EDIT
# marker, so this stamps it byte-for-byte. Edit the source, not the
# per-repo copies:
#   rundeck-plugins/.github/templates/code-review-skill.shared.md
#
# Usage:
#   scripts/sync-code-review-skill.sh [--workspace <dir>] [--check]
#
#   --workspace <dir>  Container dir holding all repo clones.
#                      Default: parent of this .github repo.
#   --check            Report what would change; make no edits (exit 1 if drift).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$GITHUB_REPO_DIR/templates/code-review-skill.shared.md"

WORKSPACE="$(cd "$GITHUB_REPO_DIR/.." && pwd)"
CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -f "$TEMPLATE" ] || { echo "Template not found: $TEMPLATE" >&2; exit 1; }

drift=0
changed=0
for repo in "$WORKSPACE"/*/; do
  repo="${repo%/}"
  name="$(basename "$repo")"
  # Skip non-repos and this .github repo itself (it has no PRs to review
  # in the same sense - its own workflow/skill files are reviewed by hand).
  [ -d "$repo/.git" ] || continue
  [ "$name" = ".github" ] && continue

  dest="$repo/.github/skills/code-review/SKILL.md"

  if [ -f "$dest" ] && diff -q "$TEMPLATE" "$dest" >/dev/null 2>&1; then
    continue
  fi

  if [ "$CHECK" -eq 1 ]; then
    echo "DRIFT: $name"
    drift=1
    continue
  fi

  mkdir -p "$repo/.github/skills/code-review"
  cp "$TEMPLATE" "$dest"
  echo "updated: $name"
  changed=$((changed + 1))
done

if [ "$CHECK" -eq 1 ]; then
  [ "$drift" -eq 0 ] && echo "All repos in sync." || echo "Drift detected."
  exit "$drift"
fi
echo "Done. Updated $changed repo(s)."
