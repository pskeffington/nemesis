#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Nemesis profile staging: copy an ArchISO releng profile, add Mac extras.
# ---------------------------------------------------------------------
set -euo pipefail

die() { printf 'nemesis: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 2 ]] || die "usage: bash scripts/prepare-profile.sh mac-intel ABSOLUTE_DESTINATION"
[[ "$1" == "mac-intel" ]] || die "only the mac-intel edition is implemented"
dest="${2%/}"
[[ "$dest" == /* ]] || die "destination must be an absolute path"
[[ ! -e "$dest" && ! -L "$dest" ]] || die "destination already exists: $dest"

# Test harnesses can select a *trusted fixture*. Actual ISO builds use the
# system-installed ArchISO profile; do not point this to unreviewed code.
source_profile="${ARCHISO_RELENG_PROFILE:-/usr/share/archiso/configs/releng}"
[[ -f "$source_profile/profiledef.sh" ]] || die "archiso releng profile is missing; install archiso"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
delta="$root/profiles/mac-intel/packages.x86_64"
overlay="$root/profiles/mac-intel/airootfs"
[[ -f "$delta" && -d "$overlay" ]] || die "Nemesis package/overlay source missing"

mkdir -p "$(dirname "$dest")"
cp -a "$source_profile" "$dest"
[[ -f "$dest/packages.x86_64" ]] || die "upstream releng packages.x86_64 not found"
[[ -d "$dest/airootfs" ]] || die "upstream releng airootfs missing"

# Keep boot media definitions from upstream; change only distribution labels,
# the package list and the read-only hardware inventory executable.
for key in iso_name iso_label iso_publisher iso_application; do
  grep -q "^$key=" "$dest/profiledef.sh" || die "upstream profile changed: missing $key"
done
grep -q '^file_permissions=(' "$dest/profiledef.sh" || die "upstream profile changed: missing file_permissions"
sed -i \
  -e 's/^iso_name=.*/iso_name="nemesis"/' \
  -e 's/^iso_label=.*/iso_label="NEMESIS_$(date -u +%Y%m)"/' \
  -e 's|^iso_publisher=.*|iso_publisher="Nemesis contributors"|' \
  -e 's|^iso_application=.*|iso_application="Nemesis Intel Mac live environment"|' \
  -e '/^file_permissions=(/a\["/usr/local/bin/nemesis-hw-report"]="0:0:755"' \
  "$dest/profiledef.sh"

# Strip comments and deduplicate package names without rewriting upstream
# sources. This allows current releng versions to change independently.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
awk '
  { sub(/#.*/, "", $0); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }
  length($0) && !seen[$0]++ { print $0 }
' "$dest/packages.x86_64" "$delta" > "$tmp"
mv "$tmp" "$dest/packages.x86_64"
cp -a "$overlay/." "$dest/airootfs/"
bash -n "$dest/profiledef.sh"
printf 'Prepared %s at %s\n' "$1" "$dest"
