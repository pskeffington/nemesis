#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Compose named MacBook Air field ISO from untouched Intel rescue overlay.
# This script only prepares a staging profile; it does not run mkarchiso.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis Air profile: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: bash scripts/prepare-air-field-profile.sh ABSOLUTE_DESTINATION"
dest="${1%/}"
[[ "$dest" == /* ]] || die "destination must be an absolute path"
[[ ! -e "$dest" && ! -L "$dest" ]] || die "destination already exists: $dest"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
delta="$root/profiles/macbook-air-field/packages.x86_64"
overlay="$root/profiles/macbook-air-field/airootfs"
[[ -f "$delta" && -d "$overlay" ]] || die "optional field overlay missing"

# Reuse the validated Mac Intel staging contract; never mutate its sources.
bash "$root/scripts/prepare-profile.sh" mac-intel "$dest"

# A distinct name and volume label avoid confusing this with the rescue ISO.
label="$(date -u +NEMAIR_%Y%m)"
sed -i \
  -e 's/^iso_name=.*/iso_name="nemesis-air"/' \
  -e "s/^iso_label=.*/iso_label=\"$label\"/" \
  -e 's|^iso_application=.*|iso_application="Nemesis MacBook Air field live environment"|' \
  -e '/^file_permissions=(/a\["/usr/local/bin/nemesis-field-check"]="0:0:755"' \
  "$dest/profiledef.sh"

# Exact name dedup preserves signed upstream package order; no new repos.
temp="$(mktemp)"
trap 'rm -f "$temp"' EXIT
awk '
  { sub(/#.*/, "", $0); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }
  length($0) && !seen[$0]++ { print $0 }
' "$dest/packages.x86_64" "$delta" > "$temp"
mv "$temp" "$dest/packages.x86_64"
cp -a "$overlay/." "$dest/airootfs/"

# ---------------------------------------------------------------------
# Field services are opt-in. Official releng may enable an SSH server and
# ModemManager via symlinks; both are unsuitable as field-media defaults.
# Only remove inherited service enablement from the disposable Air staging
# copy, never the installed ArchISO profile or generic mac-intel edition.
# Keep upstream iwd/systemd-networkd and local console recovery intact.
# ---------------------------------------------------------------------
wants="$dest/airootfs/etc/systemd/system/multi-user.target.wants"
for unit in sshd.service ModemManager.service; do
  entry="$wants/$unit"
  if [[ -L "$entry" ]]; then
    rm -- "$entry"
  elif [[ -e "$entry" ]]; then
    die "refusing to change a non-symlink unit in staged profile: $entry"
  fi
done

# ModemManager can also be requested by D-Bus despite having no startup
# symlink. Mask the unit inside the field image so it cannot probe serial
# peripherals unexpectedly; future approved modem use can deliberately
# reverse the mask in a separate, device-specific profile.
unit_dir="$dest/airootfs/etc/systemd/system"
if [[ -e "$unit_dir/ModemManager.service" || -L "$unit_dir/ModemManager.service" ]]; then
  die "unexpected pre-existing ModemManager unit in staged Air profile"
fi
ln -s /dev/null "$unit_dir/ModemManager.service"

[[ -f "$dest/airootfs/usr/local/bin/nemesis-field-check" ]] || die "readiness tool missing"
bash -n "$dest/profiledef.sh"
printf 'Prepared opt-in macbook-air-field profile: %s\n' "$dest"
