#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Arch container only: verify every modular package can be resolved from
# configured *official signed* repositories. No package installs here.
# The container setup has already run pacman -Syu --needed archiso.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'Operator package repository check: %s\n' "$*" >&2; exit 1; }
[[ -f /etc/arch-release ]] || die "requires Arch Linux CI"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Never resolve a kit against an unapproved third-party package repository.
while IFS= read -r repo; do
  case "$repo" in
    core|extra|multilib) ;;
    *) die "unexpected repository configured in Arch CI: $repo" ;;
  esac
done < <(pacman-conf --repo-list)
count=0
for manifest in "$root/profiles/mac-intel-operator/packages.x86_64" \
                "$root/profiles/mac-intel-operator/desktop.packages.x86_64" \
                "$root"/profiles/mac-intel-operator/toolkits/*.packages.x86_64; do
  [[ -f "$manifest" ]] || die "missing manifest: $manifest"
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    token="${raw%%#*}"
    token="${token//[[:space:]]/}"
    [[ -n "$token" ]] || continue
    [[ "$token" =~ ^[a-z0-9@._+:-]+$ ]] || die "unsafe package name: $token"
    pacman -Si "$token" >/dev/null || die "unresolved Arch package: $token ($manifest)"
    count=$((count + 1))
  done < "$manifest"
done
printf 'Resolved %d Operator core/desktop/optional manifest entries in signed Arch CI package databases.\\n' "$count"
