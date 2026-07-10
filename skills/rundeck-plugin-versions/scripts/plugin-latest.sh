#!/usr/bin/env bash
#
# plugin-latest.sh <plugin-repo>
#
# Print the latest released version of a rundeck-plugins plugin.
# Source of truth is GitHub Releases; falls back to clean semver tags.
# Local git tags are NOT used (they include legacy v-prefixed and -grails7/-test tags).
#
# Env:
#   ORG   GitHub org (default: rundeck-plugins)
#
set -euo pipefail

repo="${1:-}"
org="${ORG:-rundeck-plugins}"
if [ -z "$repo" ]; then
  echo "usage: plugin-latest.sh <plugin-repo>" >&2
  exit 2
fi

# 1) Latest GitHub release (authoritative)
v="$(gh release view --repo "$org/$repo" --json tagName -q .tagName 2>/dev/null || true)"
if [ -n "$v" ]; then
  echo "$v"
  exit 0
fi

# 2) Fallback: highest clean semver tag (exclude v*, *-grails7*, *-test, etc.)
v="$(gh api "repos/$org/$repo/tags" --paginate -q '.[].name' 2>/dev/null \
      | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
      | sort -V \
      | tail -1)"
if [ -n "$v" ]; then
  echo "$v"
  exit 0
fi

echo "" # nothing found; caller treats empty as unknown
exit 1
