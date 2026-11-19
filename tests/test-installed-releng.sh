#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Check Nemesis against the *installed* ArchISO releng profile on x86_64.
# Does not build an ISO or touch installed disks or firmware.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis installed-profile test: %s\n' "$*" >&2; exit 1; }
[[ -f /etc/arch-release ]] || die "requires Arch Linux or Arch-derived host"
[[ "$(uname -m)" == "x86_64" ]] || die "requires x86_64 host"
command -v pacman >/dev/null 2>&1 || die "pacman missing"
command -v diff >/dev/null 2>&1 || die "diffutils missing"
source_profile="/usr/share/archiso/configs/releng"
[[ -f "$source_profile/profiledef.sh" ]] || die "install official archiso first"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
stage="$tmp/nemesis-releng"

# Do not permit a fixture override when testing real installed Arch packages.
env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-profile.sh" mac-intel "$stage"
[[ -x "$stage/airootfs/usr/local/bin/nemesis-hw-report" ]] || die "diagnostic overlay is not executable"
cmp -s "$source_profile/pacman.conf" "$stage/pacman.conf" || die "pacman.conf unexpectedly modified"

# ArchISO profiledef.sh uses an associative permission array. Source it only
# from the signed installed ArchISO package and generated stage.
bash -c '
  set -euo pipefail
  declare -A file_permissions=()
  source "$1"
  [[ "$iso_name" == "nemesis" ]]
  [[ "$iso_label" == NEMESIS_* ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-hw-report]:-}" == "0:0:755" ]]
  [[ "${#bootmodes[@]}" -gt 0 ]]
' _ "$stage/profiledef.sh" || die "prepared profile identity/permissions invalid"

# Boot trees belong to upstream; an overlay must not silently modify them.
for part in efiboot grub syslinux; do
  if [[ -d "$source_profile/$part" ]]; then
    diff -qr "$source_profile/$part" "$stage/$part" || die "$part boot directory drifted"
  fi
done

# Arch manifest entries may overlap the Nemesis delta; deduplicate them.
awk '
  NF == 0 { exit 1 }
  seen[$0]++ { print "duplicate package: " $0 > "/dev/stderr"; exit 1 }
' "$stage/packages.x86_64" || die "invalid staged package manifest"
for required in linux intel-ucode networkmanager linux-firmware; do
  grep -Fxq "$required" "$stage/packages.x86_64" || die "missing package: $required"
done

printf 'Installed package: '
pacman -Q archiso
printf 'Upstream releng profile SHA-256: '
sha256sum "$source_profile/profiledef.sh"
printf 'Staged profile SHA-256: '
sha256sum "$stage/profiledef.sh"
printf 'Actual packaged ArchISO releng staging contract: PASS (not an ISO boot test)\n'
