#!/usr/bin/env bash
# ---------------------------------------------------------------------
# B12 source fixture: Operator assets copied from established masters.
# No root, host desktop, network, ISO builder or live workstation needed.
# ---------------------------------------------------------------------
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
dest="$tmp/operator"
mkdir -p "$dest/airootfs"
printf 'iso_name="nemesis-operator"\n' > "$dest/profiledef.sh"
bash "$root/scripts/stage-operator-brand.sh" "$dest"
[[ -f "$dest/airootfs/usr/share/color-schemes/Nemesis.colors" ]]
[[ -f "$dest/airootfs/usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/ui/main.qml" ]]
for icon in terminal radio database location drone satellite headphones shield; do
  cmp -s "$root/brand/icons/$icon.svg" "$dest/airootfs/usr/share/icons/hicolor/scalable/apps/nemesis-$icon.svg"
done
[[ ! -e "$dest/airootfs/etc/xdg/autostart" ]]
[[ ! -e "$dest/airootfs/etc/xdg/kdeglobals" ]]
[[ ! -e "$dest/airootfs/usr/share/nemesis-operator/offline.html" ]]
# Staging must reject an existing destination without modifying its contents.
if bash "$root/scripts/stage-operator-brand.sh" "$dest" >/dev/null 2>&1; then
  printf 'ERROR: repeated staging unexpectedly succeeded\n' >&2
  exit 1
fi
rescue="$tmp/rescue"
mkdir -p "$rescue/airootfs"
printf 'iso_name="nemesis"\n' > "$rescue/profiledef.sh"
if bash "$root/scripts/stage-operator-brand.sh" "$rescue" >/dev/null 2>&1; then
  printf 'ERROR: rescue profile accepted theme\n' >&2
  exit 1
fi
[[ ! -e "$rescue/airootfs/usr/share/color-schemes/Nemesis.colors" ]]
printf 'Operator brand source staging: PASS\n'
