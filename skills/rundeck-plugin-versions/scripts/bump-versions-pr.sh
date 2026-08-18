#!/usr/bin/env bash
#
# bump-versions-pr.sh
#
# Proactively close plugin-version drift: for each consuming repo
# (rundeck/Core, rundeckpro, ua-runner), bundle every bump needed to
# catch that repo up to the latest GitHub Release of each bundled
# plugin (per mapping.tsv) into ONE branch/commit/PR - not one PR per
# plugin.
#
# Unlike check-versions.sh (read-only), this edits gradle.properties,
# commits, pushes a branch, and opens a real PR. It never pushes to
# main and never merges - a human reviews and merges each PR, same as
# every other change in this org.
#
# Usage:
#   bump-versions-pr.sh [--root DIR | --rundeck DIR --rundeckpro DIR --ua-runner DIR]
#                       [--dry-run]
#
#   --root DIR     Parent dir containing all three repos (default: $HOME/Documents/GitHub).
#   --dry-run      Report what would change; make no edits, branches, or PRs.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPING="$SCRIPT_DIR/../mapping.tsv"

ROOT="${GH_ROOT:-$HOME/Documents/GitHub}"
RUNDECK="" ; RUNDECKPRO="" ; UARUNNER="" ; DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || { echo "Missing value for --root" >&2; exit 2; }; ROOT="$2"; shift 2 ;;
    --rundeck) [ $# -ge 2 ] || { echo "Missing value for --rundeck" >&2; exit 2; }; RUNDECK="$2"; shift 2 ;;
    --rundeckpro) [ $# -ge 2 ] || { echo "Missing value for --rundeckpro" >&2; exit 2; }; RUNDECKPRO="$2"; shift 2 ;;
    --ua-runner) [ $# -ge 2 ] || { echo "Missing value for --ua-runner" >&2; exit 2; }; UARUNNER="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done
RUNDECK="${RUNDECK:-$ROOT/rundeck}"
RUNDECKPRO="${RUNDECKPRO:-$ROOT/rundeckpro}"
UARUNNER="${UARUNNER:-$ROOT/ua-runner}"

[ -f "$MAPPING" ] || { echo "mapping.tsv not found at $MAPPING" >&2; exit 1; }

prop_ver() {
  local prop="$1" f="$2"
  [ -f "$f" ] || { echo ""; return; }
  grep -E "^[[:space:]]*${prop}[[:space:]]*=" "$f" 2>/dev/null | head -1 | sed -E 's/^[^=]*=[[:space:]]*//; s/[[:space:]]*$//'
}

# col: 2=core prop column, 3=rundeckpro prop column, 4=ua-runner prop column
process_repo() {
  local repo_dir="$1" repo_label="$2" col="$3"
  if [ ! -d "$repo_dir" ]; then
    echo "SKIP $repo_label: not found at $repo_dir" >&2
    return
  fi
  local props_file="$repo_dir/gradle.properties"

  # Always diff against origin/main's actual content, never whatever
  # happens to be checked out (which is often an in-progress feature
  # branch that can be stale relative to main in either direction).
  git -C "$repo_dir" fetch origin --quiet
  local remote_props
  remote_props="$(mktemp)"
  git -C "$repo_dir" show origin/main:gradle.properties > "$remote_props" 2>/dev/null || true

  local bumps_prop=() bumps_old=() bumps_new=() bumps_plugin=()

  while IFS=$'\t' read -r plugin core_prop pro_prop ua_prop; do
    case "$plugin" in ''|\#*) continue ;; esac
    local prop=""
    case "$col" in
      2) prop="$core_prop" ;;
      3) prop="$pro_prop" ;;
      4) prop="$ua_prop" ;;
    esac
    [ "$prop" = "-" ] && continue

    local latest cur
    latest="$("$SCRIPT_DIR/plugin-latest.sh" "$plugin" 2>/dev/null || true)"
    [ -z "$latest" ] && continue
    cur="$(prop_ver "$prop" "$remote_props")"
    [ -z "$cur" ] && continue
    [ "$cur" = "$latest" ] && continue

    bumps_prop+=("$prop")
    bumps_old+=("$cur")
    bumps_new+=("$latest")
    bumps_plugin+=("$plugin")
  done < "$MAPPING"
  rm -f "$remote_props"

  if [ "${#bumps_prop[@]}" -eq 0 ]; then
    echo "$repo_label: up to date, no PR needed"
    return
  fi

  echo "$repo_label: ${#bumps_prop[@]} bump(s) needed"
  local i
  for i in "${!bumps_prop[@]}"; do
    echo "  - ${bumps_plugin[$i]}: ${bumps_prop[$i]} ${bumps_old[$i]} -> ${bumps_new[$i]}"
  done

  if [ "$DRY_RUN" -eq 1 ]; then
    return
  fi

  local dirty
  dirty="$(git -C "$repo_dir" status -s | wc -l | tr -d ' ')"
  if [ "$dirty" -ne 0 ]; then
    echo "SKIP $repo_label: working tree is dirty, not touching it" >&2
    return
  fi

  # Remember whatever branch was checked out (often an in-progress feature
  # branch, not main) so we can restore it once the PR is open, instead of
  # silently leaving the repo on the new bump branch.
  local orig_branch
  orig_branch="$(git -C "$repo_dir" rev-parse --abbrev-ref HEAD)"

  git -C "$repo_dir" fetch origin --quiet
  git -C "$repo_dir" checkout main --quiet
  git -C "$repo_dir" pull --ff-only origin main --quiet

  local branch="bump-plugin-versions-$(date +%Y%m%d)"
  git -C "$repo_dir" checkout -b "$branch" --quiet 2>/dev/null || git -C "$repo_dir" checkout "$branch" --quiet

  for i in "${!bumps_prop[@]}"; do
    local prop="${bumps_prop[$i]}" new="${bumps_new[$i]}"
    sed -i.bak -E "s/^([[:space:]]*${prop}[[:space:]]*=[[:space:]]*).*/\1${new}/" "$props_file"
    rm -f "$props_file.bak"
  done

  git -C "$repo_dir" add gradle.properties

  local msg_file body_file
  msg_file="$(mktemp)"
  body_file="$(mktemp)"

  {
    echo "[RUN-0000] Bump plugin versions to latest releases"
    echo ""
    for i in "${!bumps_prop[@]}"; do
      echo "- ${bumps_plugin[$i]}: ${bumps_old[$i]} -> ${bumps_new[$i]}"
    done
  } > "$msg_file"
  git -C "$repo_dir" commit -F "$msg_file" --quiet
  rm -f "$msg_file"

  git -C "$repo_dir" push origin "$branch" --quiet

  {
    echo "## What"
    echo ""
    echo "Bumps the following bundled plugin versions to their latest GitHub Release:"
    echo ""
    echo "| Plugin | Old | New |"
    echo "|--------|-----|-----|"
    for i in "${!bumps_prop[@]}"; do
      echo "| [${bumps_plugin[$i]}](https://github.com/rundeck-plugins/${bumps_plugin[$i]}/releases/tag/${bumps_new[$i]}) | ${bumps_old[$i]} | ${bumps_new[$i]} |"
    done
    echo ""
    echo "## Why"
    echo ""
    echo "Generated by the rundeck-plugin-versions skill's pre-release sweep (scripts/bump-versions-pr.sh in rundeck-plugins/.github) - closes the gap between each plugin's latest release and what this repo has pinned. Review each version's own release notes before merging; this script does not evaluate functional/breaking-change impact itself."
  } > "$body_file"

  # [RUN-0000] matches the prefix this org's shared Renovate preset uses
  # (commitMessagePrefix in .github/default.json) - some consuming repos'
  # PR checks key off that prefix, so match it here too.
  (cd "$repo_dir" && gh pr create --title "[RUN-0000] Bump plugin versions to latest releases" --body-file "$body_file")
  rm -f "$body_file"

  if [ "$orig_branch" != "$branch" ]; then
    git -C "$repo_dir" checkout "$orig_branch" --quiet
    echo "  (restored $repo_label to original branch: $orig_branch)"
  fi
}

process_repo "$RUNDECK" "rundeck (Core)" 2
process_repo "$RUNDECKPRO" "rundeckpro" 3
process_repo "$UARUNNER" "ua-runner" 4
