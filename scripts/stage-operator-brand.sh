#!/usr/bin/env bash
# ---------------------------------------------------------------------
# B12: Install approved Nemesis brand resources into an EXISTING
# Operator ArchISO staging tree. The live globe remains the wallpaper.
# This is opt-in; no main/rescue profile or user configuration changes.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator brand: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: bash scripts/stage-operator-brand.sh ABSOLUTE_STAGED_OPERATOR_PROFILE"
dest="${1%/}"
[[ "$dest" == /* && -d "$dest/airootfs" && -f "$dest/profiledef.sh" ]] || die "expected existing absolute ArchISO profile"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
grep -Eq '^iso_name="nemesis-operator"$' "$dest/profiledef.sh" || die "refusing non-Operator profile"
command -v cmp >/dev/null || die "cmp unavailable"
command -v install >/dev/null || die "install unavailable"
# Preflight ALL targets so a collision does not leave a partial theme.
pairs=(
  'brand/theme/kde/Nemesis.colors:usr/share/color-schemes/Nemesis.colors'
  'brand/theme/konsole/Nemesis.colorscheme:usr/share/konsole/Nemesis.colorscheme'
  'brand/theme/plasma/Nemesis/metadata.json:usr/share/plasma/desktoptheme/Nemesis/metadata.json'
  'brand/theme/plasma/Nemesis/colors:usr/share/plasma/desktoptheme/Nemesis/colors'
  'brand/theme/plasma/Nemesis/plasmarc:usr/share/plasma/desktoptheme/Nemesis/plasmarc'
  'brand/identity/nemesis_emblem.svg:usr/share/icons/hicolor/scalable/apps/nemesis.svg'
  'brand/identity/nemesis_wordmark.svg:usr/share/nemesis/brand/nemesis_wordmark.svg'
  'brand/wallpapers/signal-dusk.svg:usr/share/nemesis/brand/signal-dusk.svg'
  'brand/plasmoid/org.nemesis.themecontrols/metadata.json:usr/share/plasma/plasmoids/org.nemesis.themecontrols/metadata.json'
)
for qml in main.qml ModeBoard.qml IconTile.qml; do
  pairs+=("brand/plasmoid/org.nemesis.themecontrols/contents/ui/$qml:usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/ui/$qml")
done
for icon in terminal radio database location drone satellite headphones shield; do
  pairs+=("brand/icons/$icon.svg:usr/share/icons/hicolor/scalable/apps/nemesis-$icon.svg")
  pairs+=("brand/plasmoid/org.nemesis.themecontrols/contents/images/$icon.svg:usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/images/$icon.svg")
done
for pair in "${pairs[@]}"; do
  source="${pair%%:*}"
  relative="${pair#*:}"
  [[ -f "$root/$source" && ! -L "$root/$source" ]] || die "missing or linked source: $source"
  [[ ! -e "$dest/airootfs/$relative" && ! -L "$dest/airootfs/$relative" ]] || die "target collision: $relative"
done
for icon in terminal radio database location drone satellite headphones shield; do
  cmp -s "$root/brand/icons/$icon.svg" "$root/brand/plasmoid/org.nemesis.themecontrols/contents/images/$icon.svg" || die "icon mirror mismatch: $icon"
done
for pair in "${pairs[@]}"; do
  source="${pair%%:*}"
  relative="${pair#*:}"
  install -Dm0644 "$root/$source" "$dest/airootfs/$relative"
  cmp -s "$root/$source" "$dest/airootfs/$relative" || die "copy verification failed: $relative"
done
# No kdeglobals, plasmarc override, live wallpaper replacement, or autostart.
# Plasma color and widget remain installed resources pending graphical gate.
printf 'Staged %s Nemesis brand assets into Operator profile (activation unchanged).\n' "${#pairs[@]}"
