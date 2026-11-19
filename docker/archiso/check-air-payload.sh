#!/usr/bin/env bash
# ---------------------------------------------------------------------
# CI-only inspect of the *built* Air SquashFS and ISO rootfs entry.
# No mounting, no extraction of a full large image, no hardware access.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis Air payload: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == "1" ]] || die "CI Docker guard missing"
[[ $# -eq 2 ]] || die "usage: bash docker/archiso/check-air-payload.sh ISO_FILE EVIDENCE_DIR"
iso="$1"
evidence="$2"
[[ -f "$iso" && -s "$iso" ]] || die "ISO missing or empty"
[[ -d "$evidence" ]] || die "evidence directory missing"
command -v unsquashfs >/dev/null 2>&1 || die "unsquashfs from signed squashfs-tools missing"
command -v xorriso >/dev/null 2>&1 || die "xorriso missing"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sfs="$root/.build/work-macbook-air-field/iso/arch/x86_64/airootfs.sfs"
[[ -f "$sfs" && -s "$sfs" ]] || die "expected freshly built squashfs missing"

# Verify the ISO contains the rootfs path; inspect that same build's rootfs
# separately to avoid extracting another ~1+ GB on a space-limited runner.
xorriso -indev "$iso" -find /arch/x86_64/airootfs.sfs -print > "$evidence/rootfs-entry.txt" 2>&1 || die "ISO rootfs path inspection failed"
grep -Fq '/arch/x86_64/airootfs.sfs' "$evidence/rootfs-entry.txt" || die "rootfs entry not found in ISO"

unsquashfs -ll "$sfs" etc/systemd/system > "$evidence/service-layout.txt" || die "squashfs systemd inventory failed"
unsquashfs -ll "$sfs" usr/local/bin/nemesis-field-check > "$evidence/field-check-layout.txt" || die "field readiness executable absent from rootfs"
grep -Fq '/usr/local/bin/nemesis-field-check' "$evidence/field-check-layout.txt" || die "missing field diagnostic in rootfs"

# The absence of a boot-time symlink is not sufficient for ModemManager:
# its unit must be masked against D-Bus activation in the field image.
grep -E 'etc/systemd/system/ModemManager\.service -> /dev/null' "$evidence/service-layout.txt" >/dev/null || die "ModemManager not masked"
if grep -E 'multi-user\.target\.wants/(sshd|ModemManager)\.service' "$evidence/service-layout.txt" >/dev/null; then
  die "unexpected automatic SSH or ModemManager startup in field image"
fi
for retained in iwd.service systemd-networkd.service; do
  grep -Fq "multi-user.target.wants/$retained" "$evidence/service-layout.txt" || die "network service $retained missing from field image"
done
printf 'Built SquashFS systemd policy and diagnostic payload: PASS (not boot evidence)\n'
