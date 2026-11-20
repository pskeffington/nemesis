#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Real Operator ISO assembly is only authorized on isolated GitHub Docker.
# No direct Mac/Garuda host execution; no USB, firmware or disk installation.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator ISO: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == "1" ]] || die "approved GitHub Docker CI guard missing"
[[ $# -eq 0 ]] || die "usage: bash scripts/build-operator-iso.sh"
[[ "$(uname -m)" == x86_64 && -f /etc/arch-release ]] || die "requires x86_64 Arch container"
[[ "$(id -u)" -eq 0 ]] || die "requires root inside disposable Docker only"
command -v mkarchiso >/dev/null || die "signed archiso package missing"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage="$root/.build/profile-mac-intel-operator"
work="$root/.build/work-mac-intel-operator"
out="$root/out/mac-intel-operator"
for item in "$root/.build" "$root/out" "$out"; do
  [[ ! -L "$item" ]] || die "refusing symlink path: $item"
done
[[ ! -e "$stage" && ! -L "$stage" && ! -e "$work" && ! -L "$work" ]] || die "stale operator staging/work exists"
shopt -s nullglob
old=( "$out"/nemesis-operator-*-x86_64.iso )
(( ${#old[@]} == 0 )) || die "refusing preexisting operator ISO"
mkdir -p "$root/.build" "$out"
env -u ARCHISO_RELENG_PROFILE -u NEMESIS_OPERATOR_WALLPAPER_ASSETS \
  bash "$root/scripts/prepare-operator-profile.sh" "$stage"
mkarchiso -v -w "$work" -o "$out" "$stage"
bash "$root/scripts/write-checksums.sh" "$out"
printf 'Operator ISO assembled; graphical login and Mac hardware NOT BOOT TESTED.\n'
