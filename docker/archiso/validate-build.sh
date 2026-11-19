#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Execute a real Nemesis ISO build in an ephemeral trusted CI container.
# The host bind mount is ONLY the checked-out GitHub runner workspace.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis docker build: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == "1" ]] || die "CI-only guard missing (NEMESIS_CI_DOCKER=1)"
[[ -f /etc/arch-release ]] || die "requires Arch Linux container"
[[ "$(uname -m)" == "x86_64" ]] || die "requires x86_64 container"
[[ "$(id -u)" == "0" ]] || die "requires root *inside* privileged CI container"
root="/workspace"
[[ -f "$root/AGENTS.md" && -f "$root/scripts/build-iso.sh" ]] || die "expected checked-out Nemesis source at /workspace"
cd "$root"

# Keep all generated data inside the CI checkout's ignored directories.
evidence="$root/out/docker-evidence"
mkdir -p "$evidence"
printf 'start_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$evidence/build-provenance.txt"
printf 'host_scope=ephemeral-github-actions-privileged-container\n' >> "$evidence/build-provenance.txt"
printf 'git_sha=%s\n' "$(git rev-parse HEAD)" >> "$evidence/build-provenance.txt"
printf 'machine_arch=%s\n' "$(uname -m)" >> "$evidence/build-provenance.txt"
printf 'archiso_version=%s\n' "$(pacman -Q archiso)" >> "$evidence/build-provenance.txt"
printf 'grub_version=%s\n' "$(pacman -Q grub)" >> "$evidence/build-provenance.txt"
printf 'kernel_version=%s\n' "$(uname -r)" >> "$evidence/build-provenance.txt"
printf 'free_space_before=\n' >> "$evidence/build-provenance.txt"
df -h "$root" | tee -a "$evidence/build-provenance.txt"

printf '=== Source static validation ===\n'
bash scripts/validate.sh
printf '=== Packaged ArchISO profile contract ===\n'
bash tests/test-installed-releng.sh
printf '=== Run mkarchiso (actual ISO compilation) ===\n'

# Capture the real status of mkarchiso through the tee pipeline.
set +e
bash scripts/build-iso.sh mac-intel 2>&1 | tee "$evidence/mkarchiso.log"
status="${PIPESTATUS[0]}"
set -e
printf 'mkarchiso_wrapper_exit=%s\n' "$status" >> "$evidence/build-provenance.txt"
(( status == 0 )) || die "ISO build failed with exit $status; inspect mkarchiso.log"

shopt -s nullglob
isos=( "$root"/out/mac-intel/nemesis-*-x86_64.iso )
(( ${#isos[@]} == 1 )) || die "expected exactly one new Nemesis x86_64 ISO, found ${#isos[@]}"
iso="${isos[0]}"
[[ -f "$iso" && -s "$iso" ]] || die "ISO is missing or empty"

printf '=== Portable SHA-256 checksum ===\n'
(
  cd "$root/out/mac-intel"
  sha256sum -c "${iso##*/}.sha256"
)
printf 'iso_filename=%s\n' "${iso##*/}" >> "$evidence/build-provenance.txt"
printf 'iso_bytes=%s\n' "$(stat -c '%s' "$iso")" >> "$evidence/build-provenance.txt"
printf 'iso_sha256=%s\n' "$(sha256sum "$iso" | awk '{print $1}')" >> "$evidence/build-provenance.txt"

printf '=== ISO9660 and El Torito metadata (not a boot test) ===\n'
file "$iso" | tee "$evidence/file.txt"
xorriso -indev "$iso" -report_el_torito plain > "$evidence/eltorito.txt" 2>&1 || die "El Torito metadata inspection failed"
grep -Eiq 'UEFI|EFI' "$evidence/eltorito.txt" || die "no UEFI entry identified in El Torito report"
printf 'uefi_el_torito_entry=present (metadata only)\n' >> "$evidence/build-provenance.txt"

printf 'final_state=ISO_BUILT_AND_HASH_VERIFIED_NOT_BOOT_TESTED\n' >> "$evidence/build-provenance.txt"
printf 'finish_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$evidence/build-provenance.txt"
printf 'ISO build and checksum validated; VM and Apple physical boot remain UNTESTED.\n'
