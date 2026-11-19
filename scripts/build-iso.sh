#!/usr/bin/env bash
# Build Mac Intel live ISO using ArchISO on an x86_64 Arch-family host.
set -euo pipefail

die() { printf 'nemesis: %s\n' "$*" >&2; exit 1; }
[[ $# -le 1 ]] || die "usage: sudo bash scripts/build-iso.sh [mac-intel]"
edition="${1:-mac-intel}"
[[ "$edition" == "mac-intel" ]] || die "only mac-intel is currently buildable"
[[ "$(uname -m)" == "x86_64" ]] || die "building requires an x86_64 Linux host"
[[ -f /etc/arch-release ]] || die "building requires an Arch-family Linux host"
[[ "$(id -u)" -eq 0 ]] || die "run with sudo on a trusted build host"
command -v mkarchiso >/dev/null 2>&1 || die "mkarchiso missing; install archiso"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage="$root/.build/profile-$edition"
work="$root/.build/work-$edition"
out="$root/out/$edition"
[[ ! -e "$stage" && ! -L "$stage" ]] || die "staging already exists: $stage; inspect/remove manually"
[[ ! -e "$work" && ! -L "$work" ]] || die "work directory already exists: $work; inspect/remove manually"

mkdir -p "$root/.build" "$out"
bash "$root/scripts/prepare-profile.sh" "$edition" "$stage"
printf 'Building Nemesis %s; inspect storage use before proceeding.\n' "$edition"
mkarchiso -v -w "$work" -o "$out" "$stage"

shopt -s nullglob
isos=( "$out"/nemesis-*-x86_64.iso )
(( ${#isos[@]} > 0 )) || die "mkarchiso returned without a matching Nemesis ISO"
for iso in "${isos[@]}"; do
  sha256sum "$iso" > "$iso.sha256"
  printf 'ISO: %s\nSHA256: %s.sha256\n' "$iso" "$iso"
done
printf 'Build complete; UEFI virtual and physical Mac acceptance remain separate gates.\n'
