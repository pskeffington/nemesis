#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Independent graphical Operator image. Starts from the Air field stage;
# generic mac-intel and lean macbook-air-field sources remain unchanged.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator stage: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: bash scripts/prepare-operator-profile.sh ABSOLUTE_DESTINATION"
dest="${1%/}"
[[ "$dest" == /* ]] || die "destination must be an absolute path"
[[ ! -e "$dest" && ! -L "$dest" ]] || die "refusing existing destination"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay="$root/profiles/mac-intel-operator/airootfs"
desktop="$root/profiles/mac-intel-operator/desktop.packages.x86_64"
tools="$root/profiles/mac-intel-operator/packages.x86_64"
assets="${NEMESIS_OPERATOR_WALLPAPER_ASSETS:-$root/.build/operator-assets}"
[[ -d "$overlay" && -f "$desktop" && -f "$tools" ]] || die "operator overlay or manifests absent"
[[ -f "$assets/LICENSE" && -f "$assets/provenance.txt" && -s "$assets/linux-live-wallpaper" ]] || die "pinned wallpaper build assets absent"
grep -Fxq 'source_license=MIT' "$assets/provenance.txt" || die "unreviewed source license"
actual="$(sha256sum "$assets/linux-live-wallpaper" | awk '{print $1}')"
grep -Fxq "binary_sha256=$actual" "$assets/provenance.txt" || die "wallpaper binary provenance mismatch"

bash "$root/scripts/prepare-air-field-profile.sh" "$dest"
label="$(date -u +NEMOP_%Y%m)"
sed -i \
  -e 's/^iso_name=.*/iso_name="nemesis-operator"/' \
  -e "s/^iso_label=.*/iso_label=\"$label\"/" \
  -e 's|^iso_application=.*|iso_application="Nemesis Operator Intel Mac live desktop"|' \
  -e '/^file_permissions=(/a\["/usr/local/bin/linux-live-wallpaper"]="0:0:755"\n["/usr/local/bin/nemesis-operator-wallpaper"]="0:0:755"\n["/usr/local/bin/nemesis-kit"]="0:0:755"' \
  "$dest/profiledef.sh"

temp="$(mktemp)"
trap 'rm -f "$temp"' EXIT
awk '
  { sub(/#.*/, "", $0); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }
  length($0) && !seen[$0]++ { print $0 }
' "$dest/packages.x86_64" "$desktop" "$tools" > "$temp"
mv -- "$temp" "$dest/packages.x86_64"
cp -a "$overlay/." "$dest/airootfs/"

# ---------------------------------------------------------------------
# Optional bundles ship as *text manifests*, not installed applications.
# The live account can inspect them, but installer and toolkit operations
# require a separately configured authenticated installed-system user.
# ---------------------------------------------------------------------
kit_source="$root/profiles/mac-intel-operator/toolkits"
kit_dest="$dest/airootfs/usr/share/nemesis-operator/kits"
install -d -m 0755 "$kit_dest"
for kit in aviation airspy gnss network rf-lab development gis; do
  file="$kit_source/$kit.packages.x86_64"
  [[ -f "$file" && ! -L "$file" ]] || die "optional toolkit manifest missing: $kit"
  install -m 0644 "$file" "$kit_dest/$kit.packages.x86_64"
done
[[ -f "$dest/airootfs/usr/local/bin/nemesis-kit" ]] || die "toolkit manager missing"

# The Operator KDE Plasma network applet uses NetworkManager. Remove only
# inherited Air stage *enablement links* for iwd and networkd. No changes
# to the user's host network, and no preloaded Wi-Fi credentials.
systemd="$dest/airootfs/etc/systemd/system"
wants="$systemd/multi-user.target.wants"
mkdir -p "$wants"
for unit in iwd.service systemd-networkd.service; do
  entry="$wants/$unit"
  if [[ -L "$entry" ]]; then
    rm -- "$entry"
  elif [[ -e "$entry" ]]; then
    die "unreviewed non-symlink inherited network unit: $entry"
  fi
done
[[ ! -e "$wants/NetworkManager.service" && ! -L "$wants/NetworkManager.service" ]] || die "unexpected preexisting NetworkManager enablement"
ln -s /usr/lib/systemd/system/NetworkManager.service "$wants/NetworkManager.service"

install -Dm0755 "$assets/linux-live-wallpaper" "$dest/airootfs/usr/local/bin/linux-live-wallpaper"
install -Dm0644 "$assets/LICENSE" "$dest/airootfs/usr/share/licenses/linux-live-wallpaper/LICENSE"
install -Dm0644 "$assets/provenance.txt" "$dest/airootfs/usr/share/nemesis-operator/wallpaper-provenance.txt"
[[ -f "$dest/airootfs/usr/local/bin/nemesis-operator-wallpaper" ]] || die "wallpaper launcher source missing"
bash -n "$dest/profiledef.sh"
printf 'Prepared distinct Operator ISO with pinned wallpaper: %s\n' "$dest"
