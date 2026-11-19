#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Optional Nemesis KDE ISO theme profile: never changes the default rescue.
# This is source staging; there is no autologin, default desktop or ISO boot.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis theme stage: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: bash scripts/prepare-theme-profile.sh ABSOLUTE_NEW_DESTINATION"
dest="$1"
[[ "$dest" == /* ]] || die "destination must be absolute"
[[ ! -e "$dest" && ! -L "$dest" ]] || die "destination already exists; never overwrite"
root="$(cd "$(dirname "$0")/.." && pwd -P)"
manifest="$root/profiles/mac-intel-theme-preview/packages.x86_64"
[[ -s "$manifest" ]] || die "missing preview package manifest"
for cmd in rsvg-convert file install awk sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || die "missing $cmd; builder needs librsvg and file"
done
for source in \
  "$root/brand/theme/kde/Nemesis.colors" \
  "$root/brand/theme/konsole/Nemesis.colorscheme" \
  "$root/brand/theme/plasma/Nemesis/metadata.json" \
  "$root/brand/theme/plasma/Nemesis/colors" \
  "$root/brand/theme/plasma/Nemesis/plasmarc" \
  "$root/brand/theme/wallpaper/Nemesis/metadata.json" \
  "$root/brand/identity/nemesis_emblem.svg" \
  "$root/brand/wallpapers/signal-dusk.svg" \
  "$root/LICENSE" \
  "$root/profiles/mac-intel-theme-preview/nemesis-theme-report"; do
  [[ -f "$source" && ! -L "$source" ]] || die "missing or linked source: $source"
done

# The inherited releng override is for trusted CI fixtures only.
# Production callers must unset ARCHISO_RELENG_PROFILE.
bash "$root/scripts/prepare-profile.sh" mac-intel "$dest"
[[ -d "$dest/airootfs" && -f "$dest/profiledef.sh" ]] || die "base profile incomplete"
sed -i \
  -e 's/^iso_name=.*/iso_name="nemesis-theme"/' \
  -e 's/^iso_label=.*/iso_label="NEMTHEME_PREVIEW"/' \
  -e 's|^iso_application=.*|iso_application="Nemesis KDE theme preview (unverified)"|' \
  -e '/^file_permissions=(/a\["/usr/local/bin/nemesis-theme-report"]="0:0:755"' \
  "$dest/profiledef.sh"

# Append only official Arch KDE package names; preserve upstream boot entries.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
awk '
  { sub(/#.*/, "", $0); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }
  length($0) && !seen[$0]++ { print $0 }
' "$dest/packages.x86_64" "$manifest" > "$tmp"
cat "$tmp" > "$dest/packages.x86_64"

add_asset() {
  local source="$1" relative="$2" target
  target="$dest/airootfs/$relative"
  [[ ! -e "$target" && ! -L "$target" ]] || die "overlay path collision: $relative"
  install -Dm644 "$source" "$target"
}
add_asset "$root/brand/theme/kde/Nemesis.colors" usr/share/color-schemes/Nemesis.colors
add_asset "$root/brand/theme/konsole/Nemesis.colorscheme" usr/share/konsole/Nemesis.colorscheme
add_asset "$root/brand/theme/plasma/Nemesis/metadata.json" usr/share/plasma/desktoptheme/Nemesis/metadata.json
add_asset "$root/brand/theme/plasma/Nemesis/colors" usr/share/plasma/desktoptheme/Nemesis/colors
add_asset "$root/brand/theme/plasma/Nemesis/plasmarc" usr/share/plasma/desktoptheme/Nemesis/plasmarc
add_asset "$root/brand/identity/nemesis_emblem.svg" usr/share/icons/hicolor/scalable/apps/nemesis.svg
add_asset "$root/brand/theme/wallpaper/Nemesis/metadata.json" usr/share/wallpapers/Nemesis/metadata.json
add_asset "$root/brand/wallpapers/signal-dusk.svg" usr/share/nemesis/brand/signal-dusk.svg
add_asset "$root/LICENSE" usr/share/licenses/nemesis-theme-preview/LICENSE
report="$dest/airootfs/usr/local/bin/nemesis-theme-report"
[[ ! -e "$report" ]] || die "report executable collision"
install -Dm755 "$root/profiles/mac-intel-theme-preview/nemesis-theme-report" "$report"

# Native 4K renderer, not a scaled mockup or synthetic placeholder.
wallpaper="$dest/airootfs/usr/share/wallpapers/Nemesis/contents/images/3840x2160.png"
[[ ! -e "$wallpaper" ]] || die "wallpaper collision"
mkdir -p "$(dirname "$wallpaper")"
rsvg-convert -w 3840 -h 2160 -o "$wallpaper" "$root/brand/wallpapers/signal-dusk.svg"
[[ -s "$wallpaper" ]] || die "4K wallpaper render failed"
file -b "$wallpaper" | grep -Fq 'PNG image data, 3840 x 2160' || die "wallpaper not 3840x2160 PNG"

bash -n "$dest/profiledef.sh"
grep -Fq '["/usr/local/bin/nemesis-theme-report"]="0:0:755"' "$dest/profiledef.sh" || die "missing report executable permissions"
bash -c 'declare -A file_permissions=(); source "$1"; [[ "$iso_name" == "nemesis-theme" && "$iso_label" == "NEMTHEME_PREVIEW" ]]' _ "$dest/profiledef.sh" || die "invalid profile name"
printf 'Staged optional Nemesis theme at %s (no GUI or ISO boot test)\n' "$dest"
