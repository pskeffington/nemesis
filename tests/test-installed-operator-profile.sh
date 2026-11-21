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
for pkg in plasma-desktop sddm webkitgtk-6.0 gtk4-layer-shell rtl-sdr dump1090_rs gpsd; do
  grep -Fxq "$pkg" "$stage/packages.x86_64" || die "missing operator package $pkg"
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
' _ "$stage" || die "profile metadata invalid"
# Independently stage the branded profile against real signed ArchISO releng.
# The disposable live image alone gains defaults; unbranded operator stays intact.
env -u ARCHISO_RELENG_PROFILE NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" NEMESIS_OPERATOR_BRAND=1 \
  bash "$root/scripts/prepare-operator-profile.sh" "$tmp/operator-branded"
branded="$tmp/operator-branded/airootfs"
cmp -s "$root/brand/theme/kde/Nemesis.colors" "$branded/etc/xdg/kdeglobals" || die "system KDE palette absent"
cmp -s "$root/brand/operator-defaults/plasmarc" "$branded/etc/xdg/plasmarc" || die "Plasma theme selection absent"
cmp -s "$root/brand/operator-defaults/konsolerc" "$branded/etc/xdg/konsolerc" || die "Konsole selection absent"
cmp -s "$root/brand/operator-defaults/Nemesis.profile" "$branded/usr/share/konsole/Nemesis.profile" || die "Konsole profile absent"
for icon in terminal radio database location drone satellite headphones shield; do
  cmp -s "$root/brand/icons/$icon.svg" "$branded/usr/share/icons/hicolor/scalable/apps/nemesis-$icon.svg" || die "hicolor icon diverged: $icon"
  cmp -s "$root/brand/icons/$icon.svg" "$branded/usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/images/$icon.svg" || die "widget icon diverged: $icon"
done
grep -Fxq 'Icon=nemesis-location' "$branded/usr/share/applications/nemesis-operator-airmap.desktop" || die "aircraft launcher not styled"
grep -Fxq 'Icon=nemesis-shield' "$branded/usr/share/applications/nemesis-operator-readiness.desktop" || die "readiness launcher not styled"
cmp -s "$stage/airootfs/usr/share/nemesis-operator/offline.html" "$branded/usr/share/nemesis-operator/offline.html" || die "globe offline page changed"
cmp -s "$stage/airootfs/etc/xdg/kscreenlockerrc" "$branded/etc/xdg/kscreenlockerrc" || die "live lock policy changed"
[[ ! -e "$stage/airootfs/etc/xdg/kdeglobals" ]] || die "unbranded Operator inherited theme"
printf 'Installed signed ArchISO Operator staging: PASS (not a live desktop boot)\n'
