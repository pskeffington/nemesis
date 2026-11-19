#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Optional theme ISO profile staging on real installed ArchISO, no mkarchiso.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'theme staging: %s\n' "$*" >&2; exit 1; }
[[ -f /etc/arch-release && "$(uname -m)" == "x86_64" ]] || die "requires Arch x86_64 container"
command -v pacman >/dev/null || die "missing pacman"
command -v rsvg-convert >/dev/null || die "missing librsvg"
command -v diff >/dev/null || die "missing diffutils"
root="$(cd "$(dirname "$0")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
base="$tmp/rescue"
themed="$tmp/themed"
releng="/usr/share/archiso/configs/releng"
[[ -f "$releng/profiledef.sh" ]] || die "installed releng missing"
env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-profile.sh" mac-intel "$base"
env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-theme-profile.sh" "$themed"

# Default rescue is unchanged; preview has a distinct label and asset set.
[[ ! -e "$base/airootfs/usr/share/color-schemes/Nemesis.colors" ]] || die "default ISO includes theme"
grep -Fxq 'iso_name="nemesis"' "$base/profiledef.sh" || die "default name modified"
grep -Fxq 'iso_name="nemesis-theme"' "$themed/profiledef.sh" || die "preview ISO name missing"
grep -Fxq 'iso_label="NEMTHEME_PREVIEW"' "$themed/profiledef.sh" || die "preview ISO label missing"
cmp -s "$base/pacman.conf" "$themed/pacman.conf" || die "preview modified package trust"
for part in efiboot grub syslinux; do
  if [[ -d "$releng/$part" ]]; then
    diff -qr "$releng/$part" "$themed/$part" >/dev/null || die "boot tree modified: $part"
  fi
done
for src_dst in \
 "brand/theme/kde/Nemesis.colors:usr/share/color-schemes/Nemesis.colors" \
 "brand/theme/konsole/Nemesis.colorscheme:usr/share/konsole/Nemesis.colorscheme" \
 "brand/theme/plasma/Nemesis/metadata.json:usr/share/plasma/desktoptheme/Nemesis/metadata.json" \
 "brand/theme/plasma/Nemesis/colors:usr/share/plasma/desktoptheme/Nemesis/colors" \
 "brand/theme/plasma/Nemesis/plasmarc:usr/share/plasma/desktoptheme/Nemesis/plasmarc" \
 "brand/identity/nemesis_emblem.svg:usr/share/icons/hicolor/scalable/apps/nemesis.svg" \
 "brand/theme/wallpaper/Nemesis/metadata.json:usr/share/wallpapers/Nemesis/metadata.json" \
 "brand/wallpapers/signal-dusk.svg:usr/share/nemesis/brand/signal-dusk.svg"; do
  src="$(printf '%s' "$src_dst" | cut -d: -f1)"
  dst="$(printf '%s' "$src_dst" | cut -d: -f2)"
  cmp -s "$root/$src" "$themed/airootfs/$dst" || die "asset differs: $dst"
done
png="$themed/airootfs/usr/share/wallpapers/Nemesis/contents/images/3840x2160.png"
[[ -s "$png" ]] || die "missing rendered wallpaper"
file -b "$png" | grep -Fq 'PNG image data, 3840 x 2160' || die "invalid 4K PNG"
python3 -m json.tool "$themed/airootfs/usr/share/wallpapers/Nemesis/metadata.json" >/dev/null
python3 -m json.tool "$themed/airootfs/usr/share/plasma/desktoptheme/Nemesis/metadata.json" >/dev/null
[[ -x "$themed/airootfs/usr/local/bin/nemesis-theme-report" ]] || die "diagnostic unavailable"
cmp -s "$root/LICENSE" "$themed/airootfs/usr/share/licenses/nemesis-theme-preview/LICENSE" || die "license missing"

# Resolve every optional package against the *installed* signed Arch database.
# Package metadata lookup != dependency install or an ISO build.
for pkg in plasma-desktop plasma-workspace breeze breeze-icons konsole dolphin plasma-nm plasma-pa mesa qt6-svg sddm; do
  grep -Fxq "$pkg" "$themed/packages.x86_64" || die "missing staged package: $pkg"
  pacman -Si "$pkg" >/dev/null || die "package not in official repository: $pkg"
done
for pkg in linux intel-ucode networkmanager linux-firmware; do
  grep -Fxq "$pkg" "$themed/packages.x86_64" || die "core package removed: $pkg"
done
awk 'NF==0 {bad=1} seen[$0]++ {bad=1; print "duplicate "$0 > "/dev/stderr"} END {exit bad}' "$themed/packages.x86_64" || die "manifest invalid"
if env -u ARCHISO_RELENG_PROFILE bash "$root/scripts/prepare-theme-profile.sh" "$themed" >/dev/null 2>&1; then
  die "overwrote existing staging destination"
fi
printf 'Docker releng + theme ISO staging: PASS. Image build/boot untested.\n'
