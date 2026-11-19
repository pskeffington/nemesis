#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Build optional Air ISO on explicitly approved Arch/GitHub CI environment.
# Does not replace, mutate or auto-enable the generic mac-intel rescue ISO.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis Air build: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 0 ]] || die "usage: bash scripts/build-air-field-iso.sh"
[[ "$(uname -m)" == "x86_64" ]] || die "requires x86_64 Linux"
[[ -f /etc/arch-release ]] || die "requires Arch-family Linux"
[[ "$(id -u)" -eq 0 ]] || die "requires root on authorized build environment"
command -v mkarchiso >/dev/null 2>&1 || die "mkarchiso missing"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage="$root/.build/profile-macbook-air-field"
work="$root/.build/work-macbook-air-field"
out="$root/out/macbook-air-field"

# Root build must never write through a symlink or reuse stale work/images.
for item in "$root/.build" "$root/out" "$out"; do
  [[ ! -L "$item" ]] || die "refusing symlinked path: $item"
done
[[ ! -e "$stage" && ! -L "$stage" ]] || die "staging exists: $stage; inspect before cleanup"
[[ ! -e "$work" && ! -L "$work" ]] || die "work directory exists: $work; inspect before cleanup"
shopt -s nullglob
old=( "$out"/nemesis-air-*-x86_64.iso )
(( ${#old[@]} == 0 )) || die "existing field ISO at $out; refuse stale reuse"

mkdir -p "$root/.build" "$out"
env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-air-field-profile.sh" "$stage"
printf 'Building isolated Nemesis Air field ISO from installed signed ArchISO.\n'
mkarchiso -v -w "$work" -o "$out" "$stage"

# Existing checksum generator requires exactly one fresh Nemesis ISO.
bash "$root/scripts/write-checksums.sh" "$out"
printf 'Field ISO assembled; QEMU and physical Air boot remain NOT TESTED.\n'
