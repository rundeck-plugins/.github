#!/usr/bin/env bash
#
# org-sync.sh
#
# Bulk operations across all rundeck-plugins clones in a container workspace.
#
# Modes:
#   status   (default) Read-only report: branch, dirty count, ahead/behind.
#   sync     Move each clone to its remote default branch and fast-forward.
#            With --discard, also revert tracked changes and remove untracked
#            files (git reset --hard + git clean -fd). Without --discard, dirty
#            repos are reported and skipped (no data loss).
#
# Usage:
#   scripts/org-sync.sh [status|sync] [--workspace <dir>] [--discard]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$GITHUB_REPO_DIR/.." && pwd)"

MODE="status"
DISCARD=0
while [ $# -gt 0 ]; do
  case "$1" in
    status|sync) MODE="$1"; shift ;;
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --discard) DISCARD=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

default_branch() {
  git -C "$1" remote set-head origin -a >/dev/null 2>&1 || true
  git -C "$1" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##'
}

printf "%-40s %-22s %-8s %s\n" "REPO" "BRANCH" "DIRTY" "INFO"
for repo in "$WORKSPACE"/*/; do
  repo="${repo%/}"
  name="$(basename "$repo")"
  [ -d "$repo/.git" ] || continue

  branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  dirty="$(git -C "$repo" status -s 2>/dev/null | wc -l | tr -d ' ')"

  if [ "$MODE" = "status" ]; then
    git -C "$repo" fetch origin --quiet 2>/dev/null || true
    def="$(default_branch "$repo")"
    info="default=${def:-?}"
    if [ -n "$def" ] && git -C "$repo" rev-parse --verify -q "origin/$def" >/dev/null 2>&1; then
      counts="$(git -C "$repo" rev-list --left-right --count "HEAD...origin/$def" 2>/dev/null | tr '\t' '/' || echo '?/?')"
      info="$info ahead/behind=${counts}"
    fi
    printf "%-40s %-22s %-8s %s\n" "$name" "$branch" "$dirty" "$info"
    continue
  fi

  # sync mode
  git -C "$repo" fetch origin --prune --quiet 2>/dev/null || true
  def="$(default_branch "$repo")"
  if [ -z "$def" ]; then
    printf "%-40s %-22s %-8s %s\n" "$name" "$branch" "$dirty" "SKIP: no default branch"
    continue
  fi
  if [ "$dirty" -ne 0 ] && [ "$DISCARD" -ne 1 ]; then
    printf "%-40s %-22s %-8s %s\n" "$name" "$branch" "$dirty" "SKIP: dirty (use --discard)"
    continue
  fi
  git -C "$repo" checkout "$def" --quiet 2>/dev/null || true
  if [ "$DISCARD" -eq 1 ]; then
    git -C "$repo" reset --hard "origin/$def" --quiet 2>/dev/null || true
    git -C "$repo" clean -fd --quiet 2>/dev/null || true
  else
    git -C "$repo" merge --ff-only "origin/$def" --quiet 2>/dev/null || true
  fi
  new="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  printf "%-40s %-22s %-8s %s\n" "$name" "$branch" "$dirty" "-> $new"
done
