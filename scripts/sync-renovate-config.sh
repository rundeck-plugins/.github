#!/usr/bin/env bash
#
# sync-renovate-config.sh
#
# Stamp the minimal "extends the shared preset" renovate.json into each
# active repo. The actual rules live in one place:
#   rundeck-plugins/.github/default.json
# Edit that file, not the per-repo copies.
#
# Usage:
#   scripts/sync-renovate-config.sh [--workspace <dir>] [--check]
#
#   --workspace <dir>  Container dir holding all repo clones.
#                      Default: parent of this .github repo.
#   --check            Report what would change; make no edits (exit 1 if drift).
#
set -euo pipefail

DESIRED='{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["github>rundeck-plugins/.github"]
}
'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$GITHUB_REPO_DIR/.." && pwd)"

CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

drift=0
changed=0
for repo in "$WORKSPACE"/*/; do
  repo="${repo%/}"
  name="$(basename "$repo")"
  # Skip non-repos and this .github repo itself (it has no manifests to renovate).
  [ -d "$repo/.git" ] || continue
  [ "$name" = ".github" ] && continue

  dest="$repo/renovate.json"

  if [ -f "$dest" ] && diff -q <(printf '%s' "$DESIRED") "$dest" >/dev/null 2>&1; then
    continue
  fi

  if [ "$CHECK" -eq 1 ]; then
    echo "DRIFT: $name"
    drift=1
    continue
  fi

  printf '%s' "$DESIRED" > "$dest"
  echo "updated: $name"
  changed=$((changed + 1))
done

if [ "$CHECK" -eq 1 ]; then
  [ "$drift" -eq 0 ] && echo "All repos in sync." || echo "Drift detected."
  exit "$drift"
fi
echo "Done. Updated $changed repo(s)."
