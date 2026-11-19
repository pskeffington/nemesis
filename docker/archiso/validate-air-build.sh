#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Verify optional MacBook Air ISO assembly only on disposable GitHub Docker.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis Air CI: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == "1" ]] || die "CI-only Docker guard missing"
[[ -f /etc/arch-release ]] || die "Arch Linux container required"
[[ "$(id -u)" -eq 0 ]] || die "root inside trusted CI container required"
[[ "$(uname -m)" == "x86_64" ]] || die "x86_64 required"
root="/workspace"
[[ -f "$root/spec/macbook-air-field.json" ]] || die "missing field source"
cd "$root"
evidence="$root/out/air-field-evidence"
mkdir -p "$evidence"
{
  printf 'source_sha=%s\n' "$(git rev-parse HEAD)"
  printf 'edition=macbook-air-field\n'
  printf 'archiso=%s\n' "$(pacman -Q archiso)"
  printf 'started_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
} > "$evidence/provenance.txt"

bash scripts/validate.sh
bash tests/test-installed-releng.sh

set +e
bash scripts/build-air-field-iso.sh 2>&1 | tee "$evidence/mkarchiso.log"
result="${PIPESTATUS[0]}"
set -e
printf 'mkarchiso_wrapper_exit=%s\n' "$result" >> "$evidence/provenance.txt"
(( result == 0 )) || die "Air image build failed: $result"

shopt -s nullglob
isos=( "$root"/out/macbook-air-field/nemesis-air-*-x86_64.iso )
(( ${#isos[@]} == 1 )) || die "expected exactly one new Air ISO"
iso="${isos[0]}"
[[ -f "$iso" && -s "$iso" ]] || die "ISO missing or empty"
(
  cd "$root/out/macbook-air-field"
  sha256sum -c "${iso##*/}.sha256"
)
file "$iso" | tee "$evidence/file.txt"
xorriso -indev "$iso" -report_el_torito plain > "$evidence/eltorito.txt" 2>&1 || die "El Torito scan failed"
grep -Eiq 'UEFI|EFI' "$evidence/eltorito.txt" || die "UEFI metadata not detected"

# Inspect the actual SquashFS produced by mkarchiso. The ISO's rootfs entry
# is checked separately; neither observation is a virtual/physical boot.
bash docker/archiso/check-air-payload.sh "$iso" "$evidence"

{
  printf 'iso_filename=%s\n' "${iso##*/}"
  printf 'iso_bytes=%s\n' "$(stat -c '%s' "$iso")"
  printf 'sha256=%s\n' "$(sha256sum "$iso" | awk '{print $1}')"
  printf 'status=IMAGE_BUILT_HASH_CHECKED_NOT_BOOTED\n'
} >> "$evidence/provenance.txt"
printf 'Air field image assembly verified; actual MacBook Air remains NOT TESTED.\n'
