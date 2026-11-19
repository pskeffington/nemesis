#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Write a SHA-256 sidecar using a portable, relative ISO filename.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: bash scripts/write-checksums.sh OUTPUT_DIRECTORY"
[[ -d "$1" && ! -L "$1" ]] || die "output must be an existing, non-symlink directory"
out="$(cd "$1" && pwd -P)"

shopt -s nullglob
isos=( "$out"/nemesis-*-x86_64.iso )
(( ${#isos[@]} == 1 )) || die "expected exactly one Nemesis x86_64 ISO, found ${#isos[@]}"
[[ -s "${isos[0]}" && -f "${isos[0]}" ]] || die "ISO is empty or not a regular file"

name="${isos[0]##*/}"
(
  cd "$out"
  sha256sum "$name" > "$name.sha256"
  sha256sum -c "$name.sha256"
)
printf 'ISO: %s\nSHA256 file: %s/%s.sha256\n' "${isos[0]}" "$out" "$name"
