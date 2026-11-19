#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Read-only metadata check for approved public GitHub distro sources.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis recon: %s\n' "$*" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || die "install GitHub CLI (Arch: sudo pacman -S github-cli)"
gh auth status >/dev/null 2>&1 || die "GitHub CLI authentication missing: gh auth login"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
registry="$root/docs/research/UPSTREAM_REPOS.tsv"
[[ -f "$registry" ]] || die "missing upstream registry"

while IFS='|' read -r slug branch; do
  [[ -n "$slug" && "${slug:0:1}" != "#" ]] || continue
  [[ "$slug" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "invalid repo: $slug"
  [[ "$branch" =~ ^[A-Za-z0-9_.-]+$ ]] || die "invalid branch: $branch"
  printf '\n=== %s (%s) ===\n' "$slug" "$branch"
  gh api "repos/$slug" --jq '[.full_name, (.license.spdx_id // "UNKNOWN"), .pushed_at] | @tsv'
  gh api "repos/$slug/commits/$branch" --jq '.sha'
done < "$registry"
printf '\nReview canonical Garuda GitLab ISO profiles separately.\n'
