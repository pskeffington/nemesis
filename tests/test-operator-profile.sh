#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Validate operator profile in synthetic releng fixture without root,
# network, cargo, mkarchiso, or Mac hardware.
# ---------------------------------------------------------------------
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
fixture="$tmp/releng"
assets="$tmp/assets"
stage="$tmp/operator"
mkdir -p "$fixture/airootfs/etc/systemd/system/multi-user.target.wants" "$assets"
wants="$fixture/airootfs/etc/systemd/system/multi-user.target.wants"
for unit in sshd.service ModemManager.service iwd.service systemd-networkd.service; do
  ln -s "/usr/lib/systemd/system/$unit" "$wants/$unit"
done
cat > "$fixture/profiledef.sh" <<'EOF'
#!/usr/bin/env bash
iso_name="archlinux"
iso_label="ARCH_FIXTURE"
iso_publisher="Arch Linux"
iso_application="Arch live"
bootmodes=('uefi.systemd-boot')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)
EOF
cat > "$fixture/packages.x86_64" <<'EOF'
base
linux
linux-firmware
networkmanager
EOF
printf '#!/usr/bin/env sh\nexit 0\n' > "$assets/linux-live-wallpaper"
chmod 755 "$assets/linux-live-wallpaper"
printf 'MIT License\n' > "$assets/LICENSE"
{
  printf 'source_commit=ee51045dc394f73d8151906fe9f397dd3cc94060\n'
  printf 'source_license=MIT\n'
  printf 'binary_sha256=%s\n' "$(sha256sum "$assets/linux-live-wallpaper" | awk '{print $1}')"
} > "$assets/provenance.txt"

ARCHISO_RELENG_PROFILE="$fixture" NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" \
  bash "$root/scripts/prepare-operator-profile.sh" "$stage"
[[ -s "$stage/airootfs/usr/local/bin/linux-live-wallpaper" ]]
[[ -f "$stage/airootfs/usr/local/bin/nemesis-operator-wallpaper" ]]
[[ -f "$stage/airootfs/etc/xdg/autostart/nemesis-operator-wallpaper.desktop" ]]
[[ -f "$stage/airootfs/usr/share/nemesis-operator/offline.html" ]]
[[ -f "$stage/airootfs/etc/sddm.conf.d/10-nemesis-operator-live.conf" ]]
live_locker="$stage/airootfs/etc/xdg/kscreenlockerrc"
[[ -f "$live_locker" ]]
grep -Fxq 'Autolock=false' "$live_locker"
grep -Fxq 'LockOnResume=false' "$live_locker"
grep -Fxq 'RequirePassword=false' "$live_locker"
[[ "$(readlink "$stage/airootfs/etc/systemd/system/default.target")" == "/usr/lib/systemd/system/graphical.target" ]]
[[ "$(readlink "$stage/airootfs/etc/systemd/system/display-manager.service")" == "/usr/lib/systemd/system/sddm.service" ]]
target="$stage/airootfs/etc/systemd/system/multi-user.target.wants"
[[ -L "$target/NetworkManager.service" ]]
[[ ! -L "$target/iwd.service" && ! -L "$target/systemd-networkd.service" ]]
[[ ! -L "$target/sshd.service" ]]
[[ "$(readlink "$stage/airootfs/etc/systemd/system/ModemManager.service")" == /dev/null ]]
for package in plasma-desktop sddm webkitgtk-6.0 gtk4-layer-shell rtl-sdr dump1090_rs gpsd gqrx; do
  grep -Fxq "$package" "$stage/packages.x86_64"
done
[[ "$(grep -xc networkmanager "$stage/packages.x86_64")" -eq 1 ]]
bash -c '
  declare -A file_permissions=()
  source "$1/profiledef.sh"
  [[ "$iso_name" == "nemesis-operator" ]]
  [[ "$iso_label" == NEMOP_* ]]
  [[ "${file_permissions[/usr/local/bin/linux-live-wallpaper]:-}" == "0:0:755" ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-operator-wallpaper]:-}" == "0:0:755" ]]
' _ "$stage"
# Exercise the real Operator composition with branding enabled.
# Every object must be present and identical to its canonical SVG master.
branded="$tmp/operator-branded"
ARCHISO_RELENG_PROFILE="$fixture" NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" NEMESIS_OPERATOR_BRAND=1 \
  bash "$root/scripts/prepare-operator-profile.sh" "$branded"
object_root="$branded/airootfs/usr/share/plasma/plasmoids/org.nemesis.themecontrols"
[[ -f "$object_root/metadata.json" && -f "$object_root/contents/ui/ModeBoard.qml" ]]
cmp -s "$root/brand/theme/kde/Nemesis.colors" "$branded/airootfs/usr/share/color-schemes/Nemesis.colors"
# The opt-in theme must be a real live KDE default, not just an asset directory.
cmp -s "$root/brand/theme/kde/Nemesis.colors" "$branded/airootfs/etc/xdg/kdeglobals"
cmp -s "$root/brand/operator-defaults/plasmarc" "$branded/airootfs/etc/xdg/plasmarc"
cmp -s "$root/brand/operator-defaults/konsolerc" "$branded/airootfs/etc/xdg/konsolerc"
cmp -s "$root/brand/operator-defaults/Nemesis.profile" "$branded/airootfs/usr/share/konsole/Nemesis.profile"
grep -Fxq 'DefaultProfile=Nemesis.profile' "$branded/airootfs/etc/xdg/konsolerc"
grep -Fxq 'ColorScheme=Nemesis' "$branded/airootfs/usr/share/konsole/Nemesis.profile"
grep -Fxq 'ColorScheme=Nemesis' "$branded/airootfs/etc/xdg/kdeglobals"
grep -Fxq 'name=Nemesis' "$branded/airootfs/etc/xdg/plasmarc"
branded_airmap="$branded/airootfs/usr/share/applications/nemesis-operator-airmap.desktop"
branded_readiness="$branded/airootfs/usr/share/applications/nemesis-operator-readiness.desktop"
grep -Fxq 'Icon=nemesis-location' "$branded_airmap"
grep -Fxq 'Icon=nemesis-shield' "$branded_readiness"
cmp -s "$root/profiles/mac-intel-operator/airootfs/usr/share/applications/nemesis-operator-airmap.desktop" "$stage/airootfs/usr/share/applications/nemesis-operator-airmap.desktop"
cmp -s "$root/profiles/mac-intel-operator/airootfs/usr/share/applications/nemesis-operator-readiness.desktop" "$stage/airootfs/usr/share/applications/nemesis-operator-readiness.desktop"
grep -Fxq 'Exec=firefox --new-window https://globe.airplanes.live/' "$branded_airmap"
grep -Fxq 'Exec=konsole --hold -e /usr/local/bin/nemesis-field-check' "$branded_readiness"
for icon in terminal radio database location drone satellite headphones shield; do
  cmp -s "$root/brand/icons/$icon.svg" "$branded/airootfs/usr/share/icons/hicolor/scalable/apps/nemesis-$icon.svg"
  cmp -s "$root/brand/icons/$icon.svg" "$object_root/contents/images/$icon.svg"
done
[[ -f "$branded/airootfs/etc/xdg/autostart/nemesis-operator-wallpaper.desktop" ]]
cmp -s "$stage/airootfs/usr/share/nemesis-operator/offline.html" "$branded/airootfs/usr/share/nemesis-operator/offline.html"
cmp -s "$stage/airootfs/etc/xdg/kscreenlockerrc" "$branded/airootfs/etc/xdg/kscreenlockerrc"
[[ ! -e "$stage/airootfs/usr/share/color-schemes/Nemesis.colors" ]]
[[ ! -e "$stage/airootfs/etc/xdg/kdeglobals" ]]
[[ ! -e "$stage/airootfs/etc/xdg/plasmarc" ]]
[[ ! -e "$stage/airootfs/etc/xdg/konsolerc" ]]
[[ ! -e "$stage/airootfs/usr/share/konsole/Nemesis.profile" ]]
# Re-running a one-shot branded stage must fail before changing existing files.
if bash "$root/scripts/stage-operator-brand.sh" "$branded" >/dev/null 2>&1; then
  printf 'ERROR: repeated brand staging accepted\n' >&2
  exit 1
fi
grep -Fxq 'Icon=nemesis-location' "$branded_airmap"
[[ ! -e "$stage/airootfs/usr/share/plasma/plasmoids/org.nemesis.themecontrols" ]]
# Invalid flag must reject rather than silently changing profile selection.
if ARCHISO_RELENG_PROFILE="$fixture" NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" NEMESIS_OPERATOR_BRAND=yes \
    bash "$root/scripts/prepare-operator-profile.sh" "$tmp/invalid-brand-flag" >/dev/null 2>&1; then
  printf 'ERROR: invalid theme flag accepted\n' >&2
  exit 1
fi
if ARCHISO_RELENG_PROFILE="$fixture" NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" \
    bash "$root/scripts/prepare-operator-profile.sh" "$stage" >/dev/null 2>&1; then
  printf 'ERROR: staging overwritten\n' >&2
  exit 1
fi
printf 'Operator source/desktop/network/wallpaper staging fixture: PASS\n'
