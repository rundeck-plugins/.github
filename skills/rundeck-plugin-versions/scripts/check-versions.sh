#!/usr/bin/env bash
#
# check-versions.sh - read-only plugin version drift report across rundeck, rundeckpro, ua-runner.
#
# For each plugin in mapping.tsv it compares the latest released version (GitHub Releases)
# against the value currently used in each consuming repo:
#   - rundeck (Core):   rundeck/gradle.properties   (<prop>=<ver>)
#   - rundeckpro:       rundeckpro/gradle.properties   (<prop>=<ver>)
#   - ua-runner:        ua-runner/gradle.properties    (<prop>=<ver>)
#
# Read-only. Exits non-zero if any drift is found (useful as a pre-release gate).
#
# Usage:
#   check-versions.sh [--rundeck DIR] [--rundeckpro DIR] [--ua-runner DIR]
#                     [--plugin NAME] [--root DIR]
#
#   --root DIR      Parent dir containing all three repos (default: $HOME/Documents/GitHub,
#                   or the parent of this skill's checkout if it lives beside them).
#   --plugin NAME   Limit to a single plugin repo (e.g. ansible-plugin).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPING="$SCRIPT_DIR/../mapping.tsv"

ROOT="${GH_ROOT:-$HOME/Documents/GitHub}"
RUNDECK="" ; RUNDECKPRO="" ; UARUNNER="" ; ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --rundeck) RUNDECK="$2"; shift 2 ;;
    --rundeckpro) RUNDECKPRO="$2"; shift 2 ;;
    --ua-runner) UARUNNER="$2"; shift 2 ;;
    --plugin) ONLY="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done
RUNDECK="${RUNDECK:-$ROOT/rundeck}"
RUNDECKPRO="${RUNDECKPRO:-$ROOT/rundeckpro}"
UARUNNER="${UARUNNER:-$ROOT/ua-runner}"

[ -f "$MAPPING" ] || { echo "mapping.tsv not found at $MAPPING" >&2; exit 1; }

warn_missing() { [ -e "$1" ] || echo "WARN: repo path not found: $1" >&2; }
warn_missing "$RUNDECK"; warn_missing "$RUNDECKPRO"; warn_missing "$UARUNNER"

# --- readers -----------------------------------------------------------------
# Value of a property in a gradle.properties file.
prop_ver() {
  local prop="$1" f="$2"
  [ -f "$f" ] || { echo ""; return; }
  grep -E "^[[:space:]]*${prop}[[:space:]]*=" "$f" 2>/dev/null | head -1 | sed -E 's/^[^=]*=[[:space:]]*//; s/[[:space:]]*$//'
}

# Snapshot origin/main's actual gradle.properties rather than reading the
# working tree directly. If a repo happens to be checked out on a stale
# feature branch, reading the working tree would report false drift (or
# mask real drift) - this was found for real running an early version of
# the companion bump-versions-pr.sh against rundeck while it was on an
# in-progress feature branch.
snapshot_main_props() {
  local dir="$1"
  [ -d "$dir" ] || { echo ""; return; }
  git -C "$dir" fetch origin --quiet 2>/dev/null || true
  local tmp
  tmp="$(mktemp)"
  git -C "$dir" show origin/main:gradle.properties > "$tmp" 2>/dev/null || true
  echo "$tmp"
}

RUNDECK_SNAPSHOT="$(snapshot_main_props "$RUNDECK")"
RUNDECKPRO_SNAPSHOT="$(snapshot_main_props "$RUNDECKPRO")"
UARUNNER_SNAPSHOT="$(snapshot_main_props "$UARUNNER")"
cleanup_snapshots() { rm -f "$RUNDECK_SNAPSHOT" "$RUNDECKPRO_SNAPSHOT" "$UARUNNER_SNAPSHOT" 2>/dev/null || true; }
trap cleanup_snapshots EXIT

cell() { # value latest -> "value" or "value*" (mismatch) or "-"
  local val="$1" latest="$2"
  if [ -z "$val" ]; then echo "-"; return; fi
  if [ -n "$latest" ] && [ "$val" != "$latest" ]; then echo "${val}*"; else echo "$val"; fi
}

printf "%-38s %-10s %-12s %-12s %-12s %s\n" "PLUGIN" "LATEST" "CORE" "RUNDECKPRO" "UA-RUNNER" "STATUS"
printf "%-38s %-10s %-12s %-12s %-12s %s\n" "------" "------" "----" "----------" "---------" "------"

drift=0 ; unknown=0
while IFS=$'\t' read -r plugin core_prop pro_prop ua_prop; do
  case "$plugin" in ''|\#*) continue ;; esac
  [ -n "$ONLY" ] && [ "$plugin" != "$ONLY" ] && continue

  latest="$("$SCRIPT_DIR/plugin-latest.sh" "$plugin" 2>/dev/null || true)"

  core_v="" ; pro_v="" ; ua_v=""
  [ "$core_prop" != "-" ] && core_v="$(prop_ver "$core_prop" "$RUNDECK_SNAPSHOT")"
  [ "$pro_prop" != "-" ] && pro_v="$(prop_ver "$pro_prop" "$RUNDECKPRO_SNAPSHOT")"
  [ "$ua_prop" != "-" ] && ua_v="$(prop_ver "$ua_prop" "$UARUNNER_SNAPSHOT")"

  status="OK"
  if [ -z "$latest" ]; then
    status="UNKNOWN"; unknown=$((unknown+1))
  else
    for v in "$core_v" "$pro_v" "$ua_v"; do
      if [ -n "$v" ] && [ "$v" != "$latest" ]; then status="DRIFT"; drift=$((drift+1)); break; fi
    done
  fi

  printf "%-38s %-10s %-12s %-12s %-12s %s\n" \
    "$plugin" "${latest:-?}" \
    "$(cell "$core_v" "$latest")" \
    "$(cell "$pro_v" "$latest")" \
    "$(cell "$ua_v" "$latest")" \
    "$status"
done < "$MAPPING"

echo
echo "Legend: '*' = differs from latest release; '-' = not consumed in that repo."
echo "Drift: $drift plugin(s) behind; Unknown latest: $unknown."
[ "$drift" -eq 0 ]
