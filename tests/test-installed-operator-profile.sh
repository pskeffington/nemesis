#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Source-level Operator staging against signed installed releng. No browser
# binary is compiled here; the fixture simulates a valid pinned artifact.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator releng: %s\n' "$*" >&2; exit 1; }
[[ -f /etc/arch-release && "$(uname -m)" == x86_64 ]] || die "requires x86_64 Arch"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream=/usr/share/archiso/configs/releng
[[ -f "$upstream/profiledef.sh" ]] || die "installed ArchISO releng missing"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
assets="$tmp/assets"
mkdir -p "$assets"
printf '#!/bin/sh\nexit 0\n' > "$assets/linux-live-wallpaper"
chmod 755 "$assets/linux-live-wallpaper"
printf 'MIT License\n' > "$assets/LICENSE"
{
  printf 'source_license=MIT\n'
  printf 'binary_sha256=%s\n' "$(sha256sum "$assets/linux-live-wallpaper" | awk '{print $1}')"
} > "$assets/provenance.txt"
env -u ARCHISO_RELENG_PROFILE NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" \
  bash "$root/scripts/prepare-operator-profile.sh" "$tmp/operator"
stage="$tmp/operator"
cmp "$stage/pacman.conf" "$upstream/pacman.conf" || die "signed pacman trust policy changed"
for folder in efiboot grub syslinux; do
  if [[ -d "$upstream/$folder" ]]; then
    diff -qr "$upstream/$folder" "$stage/$folder" || die "unexpected boot tree difference"
  fi
done
for pkg in plasma-desktop sddm webkitgtk-6.0 gtk4-layer-shell rtl-sdr airspy dump1090_rs; do
  grep -Fxq "$pkg" "$stage/packages.x86_64" || die "missing operator package $pkg"
done
[[ -f "$stage/airootfs/usr/local/bin/nemesis-kit" ]] || die "kit command missing"
[[ -f "$stage/airootfs/usr/share/nemesis-operator/kits/gnss.packages.x86_64" ]] || die "kit manifest not copied"
for excluded in gqrx gnuradio gpsd qgis nmap tcpdump rtl_433; do
  if grep -Fxq "$excluded" "$stage/packages.x86_64"; then
    die "optional package auto-selected: $excluded"
  fi
done
[[ "$(readlink "$stage/airootfs/etc/systemd/system/default.target")" == "/usr/lib/systemd/system/graphical.target" ]] || die "graphical target missing"
[[ "$(readlink "$stage/airootfs/etc/systemd/system/display-manager.service")" == "/usr/lib/systemd/system/sddm.service" ]] || die "sddm link missing"
[[ -L "$stage/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service" ]] || die "NM enablement missing"
[[ ! -L "$stage/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service" ]] || die "competing iwd enabled"
[[ ! -L "$stage/airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service" ]] || die "competing networkd enabled"
[[ ! -L "$stage/airootfs/etc/systemd/system/multi-user.target.wants/sshd.service" ]] || die "remote login enabled"
[[ "$(readlink "$stage/airootfs/etc/systemd/system/ModemManager.service")" == /dev/null ]] || die "ModemManager not masked"
bash -c '
  set -euo pipefail
  declare -A file_permissions=()
  source "$1/profiledef.sh"
  [[ "$iso_name" == "nemesis-operator" ]]
  [[ "$iso_label" == NEMOP_* ]]
  [[ "${file_permissions[/usr/local/bin/linux-live-wallpaper]:-}" == "0:0:755" ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-operator-wallpaper]:-}" == "0:0:755" ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-kit]:-}" == "0:0:755" ]]
' _ "$stage" || die "profile metadata invalid"
printf 'Installed signed ArchISO Operator staging: PASS (not a live desktop boot)\n'
