#!/usr/bin/env bash
#
# audit-consumption.sh
#
# Read-only sanity check for mapping.tsv itself: for every plugin marked
# "-" (not consumed) in rundeckpro or ua-runner, search that repo's whole
# tree for a real dependency reference to it. If one is found, mapping.tsv
# is probably wrong - print a warning instead of silently trusting the
# existing "-".
#
# Why this exists: mapping.tsv had two real gaps found the hard way
# (2026-09-16/17) - 7 plugins marked vestigial/unconsumed in rundeckpro
# that were actually bundled via a real dependency list in its root
# build.gradle, and 4 plugins ua-runner bundles via a submodule-read
# mechanism no doc mentioned. Both were found by manually grepping one
# plugin at a time after something else went wrong. This script does that
# sweep for every "-" cell up front, so a gap surfaces before it causes a
# missed bump rather than after.
#
# Deliberately covers BOTH Gradle dependency syntaxes:
#   - compact:  "group:artifact:version"              e.g. "org.rundeck.plugins:docker:2.0.1"
#   - verbose:  group: '...', name: 'artifact', ...    e.g. rundeck-ec2-nodes-plugin's real declaration
# A grep for only the compact form is exactly what missed rundeck-ec2-nodes-plugin
# the first time this kind of sweep was tried.
#
# This is a heuristic, not a precise dependency-graph tool: it flags
# candidates for a human to look at, same spirit as check-versions.sh's
# DRIFT report. False positives are possible (e.g. a plugin name
# mentioned only in a comment); read the surrounding line before editing
# mapping.tsv or bump-versions-pr.sh off of it.
#
# Usage:
#   audit-consumption.sh [--root DIR | --rundeckpro DIR --ua-runner DIR]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPING="$SCRIPT_DIR/../mapping.tsv"

ROOT="${GH_ROOT:-$HOME/Documents/GitHub}"
RUNDECKPRO="" ; UARUNNER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || { echo "Missing value for --root" >&2; exit 2; }; ROOT="$2"; shift 2 ;;
    --rundeckpro) [ $# -ge 2 ] || { echo "Missing value for --rundeckpro" >&2; exit 2; }; RUNDECKPRO="$2"; shift 2 ;;
    --ua-runner) [ $# -ge 2 ] || { echo "Missing value for --ua-runner" >&2; exit 2; }; UARUNNER="$2"; shift 2 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done
RUNDECKPRO="${RUNDECKPRO:-$ROOT/rundeckpro}"
UARUNNER="${UARUNNER:-$ROOT/ua-runner}"

[ -f "$MAPPING" ] || { echo "mapping.tsv not found at $MAPPING" >&2; exit 1; }

# Search a repo's whole tracked tree (git-tracked only, so build output and
# the nested rundeck/ submodule checkout - which is its own repo - don't
# produce noise) for either Gradle dependency syntax referencing a plugin.
find_reference() {
  local repo_dir="$1" plugin="$2"
  [ -d "$repo_dir/.git" ] || return 1
  git -C "$repo_dir" grep -lE \
    "org\.rundeck[.a-zA-Z]*:${plugin}[:'\"]|name:[[:space:]]*['\"]${plugin}['\"]" \
    -- '*.gradle' '*.gradle.kts' 2>/dev/null | grep -v '^rundeck/' || true
}

found_any=0
while IFS=$'\t' read -r plugin core_prop pro_prop ua_prop; do
  case "$plugin" in ''|\#*) continue ;; esac

  if [ "$pro_prop" = "-" ]; then
    hits="$(find_reference "$RUNDECKPRO" "$plugin")"
    if [ -n "$hits" ]; then
      echo "POSSIBLE GAP: $plugin marked '-' for rundeckpro, but referenced in:"
      echo "$hits" | sed 's/^/  rundeckpro\//'
      found_any=1
    fi
  fi

  if [ "$ua_prop" = "-" ]; then
    hits="$(find_reference "$UARUNNER" "$plugin")"
    if [ -n "$hits" ]; then
      echo "POSSIBLE GAP: $plugin marked '-' for ua-runner, but referenced in:"
      echo "$hits" | sed 's/^/  ua-runner\//'
      found_any=1
    fi
  fi
done < "$MAPPING"

if [ "$found_any" -eq 0 ]; then
  echo "No gaps found: every plugin marked '-' in mapping.tsv has no dependency reference in the corresponding repo tree."
else
  echo
  echo "Review each hit above - it may be a real gap (fix mapping.tsv), or a false positive (e.g. a comment mentioning the plugin name)."
fi
