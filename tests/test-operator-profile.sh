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
if ARCHISO_RELENG_PROFILE="$fixture" NEMESIS_OPERATOR_WALLPAPER_ASSETS="$assets" \
    bash "$root/scripts/prepare-operator-profile.sh" "$stage" >/dev/null 2>&1; then
  printf 'ERROR: staging overwritten\n' >&2
  exit 1
fi
printf 'Operator source/desktop/network/wallpaper staging fixture: PASS\n'
