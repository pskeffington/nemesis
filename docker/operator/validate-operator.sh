#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Trusted main GitHub runner: build ISO, hash, UEFI metadata, payload.
# Compilation of pinned Rust source happens in an earlier unprivileged job
# step. This CI step is privileged only for mkarchiso rootfs operations.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator Docker: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == 1 && "$(id -u)" -eq 0 ]] || die "trusted privileged CI required"
[[ -f /etc/arch-release && "$(uname -m)" == x86_64 ]] || die "Arch x86_64 Docker required"
root=/workspace
[[ -f "$root/spec/operator-edition.json" ]] || die "missing repo source"
cd "$root"
evidence="$root/out/operator-evidence"
mkdir -p "$evidence"
{
  printf 'repository_sha=%s\n' "$(git rev-parse HEAD)"
  printf 'archiso=%s\n' "$(pacman -Q archiso)"
  printf 'wallpaper_source_sha=%s\n' "$(sed -n 's/^source_commit=//p' .build/operator-assets/provenance.txt)"
  printf 'start_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
} > "$evidence/provenance.txt"
bash scripts/validate.sh
bash tests/test-installed-operator-profile.sh

set +e
bash scripts/build-operator-iso.sh 2>&1 | tee "$evidence/mkarchiso.log"
status="${PIPESTATUS[0]}"
set -e
printf 'build_exit=%s\n' "$status" >> "$evidence/provenance.txt"
(( status == 0 )) || die "operator mkarchiso failed: $status"
shopt -s nullglob
isos=( "$root"/out/mac-intel-operator/nemesis-operator-*-x86_64.iso )
(( ${#isos[@]} == 1 )) || die "expected one new Operator image"
iso="${isos[0]}"
[[ -s "$iso" ]] || die "operator ISO is empty"
(
  cd "$root/out/mac-intel-operator"
  sha256sum -c "${iso##*/}.sha256"
)
file "$iso" > "$evidence/file.txt"
xorriso -indev "$iso" -report_el_torito plain > "$evidence/eltorito.txt" 2>&1 || die "ISO boot metadata failed"
grep -Eiq '(EFI|UEFI)' "$evidence/eltorito.txt" || die "UEFI metadata absent"
bash docker/operator/check-payload.sh "$iso" "$evidence"
{
  printf 'iso_name=%s\n' "${iso##*/}"
  printf 'iso_bytes=%s\n' "$(stat -c '%s' "$iso")"
  printf 'iso_sha256=%s\n' "$(sha256sum "$iso" | awk '{print $1}')"
  printf 'status=BUILT_HASHED_EFI_PAYLOAD_VALIDATED_NOT_BOOTED\n'
} >> "$evidence/provenance.txt"
printf 'Operator ISO with aircraft map and tool payload: CI PASS; live desktop boot NOT TESTED.\n'
