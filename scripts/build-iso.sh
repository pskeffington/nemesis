#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Nemesis Intel-Mac ISO builder: staged profile, isolated work, fresh ISO.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis: %s\n' "$*" >&2; exit 1; }
[[ $# -le 1 ]] || die "usage: bash scripts/build-iso.sh [mac-intel|mac-intel-theme-preview]"
edition="${1:-mac-intel}"
[[ "$edition" == "mac-intel" || "$edition" == "mac-intel-theme-preview" ]] || die "unknown ISO edition"
[[ "$(uname -m)" == "x86_64" ]] || die "building requires an x86_64 Linux host"
[[ -f /etc/arch-release ]] || die "building requires an Arch-family Linux host"
[[ "$(id -u)" -eq 0 ]] || die "run with sudo on a trusted build host"
command -v mkarchiso >/dev/null 2>&1 || die "mkarchiso missing; install archiso"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage="$root/.build/profile-$edition"
work="$root/.build/work-$edition"
out="$root/out/$edition"

# Do not follow unreviewed symlinked staging/output directories as root.
for path in "$root/.build" "$root/out" "$out"; do
  [[ ! -L "$path" ]] || die "refusing symlinked build/output path: $path"
done
[[ ! -e "$stage" && ! -L "$stage" ]] || die "staging already exists: $stage; inspect/remove manually"
[[ ! -e "$work" && ! -L "$work" ]] || die "work directory already exists: $work; inspect/remove manually"

# Refuse existing artifacts, so a stale ISO can never be reported as new.
shopt -s nullglob
previous=( "$out"/nemesis-*-x86_64.iso )
(( ${#previous[@]} == 0 )) || die "existing Nemesis ISO in $out; inspect/archive it before rebuilding"

mkdir -p "$root/.build" "$out"
if [[ "$edition" == "mac-intel-theme-preview" ]]; then
  env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-theme-profile.sh" "$stage"
else
  env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-profile.sh" "$edition" "$stage"
fi
printf 'Building Nemesis %s from installed archiso releng.\n' "$edition"
mkarchiso -v -w "$work" -o "$out" "$stage"

bash "$root/scripts/write-checksums.sh" "$out"
printf 'Build complete; UEFI VM and physical Mac acceptance are separate gates.\n'
