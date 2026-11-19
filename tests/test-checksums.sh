#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Fixture test: checksums must verify from the ISO output directory.
# ---------------------------------------------------------------------
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
out="$tmp/out"
mkdir -p "$out"
printf 'Nemesis ISO checksum fixture\n' > "$out/nemesis-test-x86_64.iso"

bash "$root/scripts/write-checksums.sh" "$out"
(
  cd "$out"
  sha256sum -c nemesis-test-x86_64.iso.sha256
)

# Relative filename only: a checksum sidecar must be portable to other hosts.
if grep -Fq "$tmp" "$out/nemesis-test-x86_64.iso.sha256"; then
  printf 'ERROR: checksum embeds an absolute build path\n' >&2
  exit 1
fi

printf 'corruption\n' >> "$out/nemesis-test-x86_64.iso"
if (cd "$out" && sha256sum -c nemesis-test-x86_64.iso.sha256 >/dev/null 2>&1); then
  printf 'ERROR: changed ISO unexpectedly verified\n' >&2
  exit 1
fi
printf 'Portable checksum and corruption detection: passed\n'
