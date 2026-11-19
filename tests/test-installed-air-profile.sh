#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Contract test against the real signed ArchISO releng profile. This tests
# staged files only: it does not install a package, build an ISO or change
# host services. Run inside native Arch Linux CI with archiso installed.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis Air releng test: %s\n' "$*" >&2; exit 1; }
[[ -f /etc/arch-release ]] || die "requires Arch Linux or an Arch derivative"
[[ "$(uname -m)" == "x86_64" ]] || die "requires x86_64"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream="/usr/share/archiso/configs/releng"
[[ -f "$upstream/profiledef.sh" ]] || die "signed archiso releng profile missing"
[[ -f "$upstream/packages.x86_64" && -f "$upstream/pacman.conf" ]] || die "upstream profile incomplete"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
stage="$tmp/air"

# Production profile always uses installed releng, never a fixture override.
env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-air-field-profile.sh" "$stage"
[[ -f "$stage/airootfs/usr/local/bin/nemesis-field-check" ]] || die "field diagnostic missing"
[[ -f "$stage/airootfs/usr/local/bin/nemesis-hw-report" ]] || die "rescue diagnostic missing"
cmp -s "$upstream/pacman.conf" "$stage/pacman.conf" || die "pacman trust configuration changed"
for folder in efiboot grub syslinux; do
  if [[ -d "$upstream/$folder" ]]; then
    diff -qr "$upstream/$folder" "$stage/$folder" || die "unexpected $folder boot drift"
  fi
done
bash -c '
  set -euo pipefail
  declare -A file_permissions=()
  source "$1"
  [[ "$iso_name" == "nemesis-air" && "$iso_label" == NEMAIR_* ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-field-check]:-}" == "0:0:755" ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-hw-report]:-}" == "0:0:755" ]]
' _ "$stage/profiledef.sh" || die "Air identity or executable permissions invalid"
for pkg in bluez bluez-utils powertop wireguard-tools intel-ucode linux-firmware; do
  grep -Fxq "$pkg" "$stage/packages.x86_64" || die "missing required Air/Intel package: $pkg"
done
awk '
  NF == 0 { exit 1 }
  seen[$0]++ { print "duplicate package: " $0 > "/dev/stderr"; exit 1 }
' "$stage/packages.x86_64" || die "duplicate/empty package line in Air image"

base_wants="$upstream/airootfs/etc/systemd/system/multi-user.target.wants"
air_wants="$stage/airootfs/etc/systemd/system/multi-user.target.wants"
for unit in sshd.service ModemManager.service; do
  [[ ! -e "$air_wants/$unit" && ! -L "$air_wants/$unit" ]] || die "unexpected auto-enabled field service: $unit"
  if [[ -L "$base_wants/$unit" ]]; then
    [[ -L "$base_wants/$unit" ]] || die "upstream service entry unexpectedly changed: $unit"
  fi
done
[[ "$(readlink "$stage/airootfs/etc/systemd/system/ModemManager.service")" == "/dev/null" ]] || die "ModemManager is not masked"
[[ ! -L "$stage/airootfs/etc/systemd/system/dbus-org.freedesktop.ModemManager1.service" ]] || die "ModemManager D-Bus alias remains enabled"
for unit in iwd.service systemd-networkd.service; do
  if [[ -L "$base_wants/$unit" ]]; then
    [[ -L "$air_wants/$unit" ]] || die "upstream network service missing: $unit"
  fi
done
printf 'ArchISO package: '
pacman -Q archiso
printf 'Air field staging policy (boot/pacman/service/isolation): PASS\n'
