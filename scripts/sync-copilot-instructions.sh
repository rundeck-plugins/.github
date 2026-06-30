#!/usr/bin/env bash
#
# sync-copilot-instructions.sh
#
# Stamp the shared Copilot instructions into each active repo's
# .github/copilot-instructions.md, leveraging the canonical org guide.
#
# The generated file is a header (auto-generated marker) followed by the
# shared template content. Edit the source template, not the per-repo copies:
#   rundeck-plugins/.github/templates/copilot-instructions.shared.md
#
# Usage:
#   scripts/sync-copilot-instructions.sh [--workspace <dir>] [--check]
#
#   --workspace <dir>  Container dir holding all repo clones.
#                      Default: parent of this .github repo.
#   --check            Report what would change; make no edits (exit 1 if drift).
#
set -euo pipefail

GENERATED_HEADER="<!-- AUTO-GENERATED from rundeck-plugins/.github/templates/copilot-instructions.shared.md -- DO NOT EDIT. Run scripts/sync-copilot-instructions.sh to update. -->"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$GITHUB_REPO_DIR/templates/copilot-instructions.shared.md"

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

build_content() {
  printf '%s\n\n' "$GENERATED_HEADER"
  cat "$TEMPLATE"
}

drift=0
changed=0
for repo in "$WORKSPACE"/*/; do
  repo="${repo%/}"
  name="$(basename "$repo")"
  # Skip non-repos and this .github repo itself.
  [ -d "$repo/.git" ] || continue
  [ "$name" = ".github" ] && continue

  dest="$repo/.github/copilot-instructions.md"
  desired="$(build_content)"

  if [ -f "$dest" ] && diff -q <(printf '%s' "$desired") "$dest" >/dev/null 2>&1; then
    continue
  fi

  if [ "$CHECK" -eq 1 ]; then
    echo "DRIFT: $name"
    drift=1
    continue
  fi

  mkdir -p "$repo/.github"
  printf '%s' "$desired" > "$dest"
  echo "updated: $name"
  changed=$((changed + 1))
done

if [ "$CHECK" -eq 1 ]; then
  [ "$drift" -eq 0 ] && echo "All repos in sync." || echo "Drift detected."
  exit "$drift"
fi
echo "Done. Updated $changed repo(s)."
