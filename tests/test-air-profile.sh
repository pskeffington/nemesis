#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Test Air overlay without Arch Linux, root, package install or mkarchiso.
# ---------------------------------------------------------------------
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
fixture="$tmp/releng"
stage="$tmp/air"
mkdir -p "$fixture/airootfs/etc/systemd/system/multi-user.target.wants"
wants="$fixture/airootfs/etc/systemd/system/multi-user.target.wants"
for unit in sshd.service ModemManager.service iwd.service systemd-networkd.service; do
  ln -s "/usr/lib/systemd/system/$unit" "$wants/$unit"
done
ln -s /usr/lib/systemd/system/ModemManager.service \
  "$fixture/airootfs/etc/systemd/system/dbus-org.freedesktop.ModemManager1.service"
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
bluez
linux-firmware
EOF

ARCHISO_RELENG_PROFILE="$fixture" bash "$root/scripts/prepare-air-field-profile.sh" "$stage"
[[ -f "$stage/airootfs/usr/local/bin/nemesis-hw-report" ]]
[[ -f "$stage/airootfs/usr/local/bin/nemesis-field-check" ]]

# Inherited remote-login and modem probing cannot start automatically on
# field laptops. Leave upstream wireless/network service wiring unchanged.
air_wants="$stage/airootfs/etc/systemd/system/multi-user.target.wants"
[[ ! -e "$air_wants/sshd.service" && ! -L "$air_wants/sshd.service" ]]
[[ ! -e "$air_wants/ModemManager.service" && ! -L "$air_wants/ModemManager.service" ]]
[[ -L "$air_wants/iwd.service" && -L "$air_wants/systemd-networkd.service" ]]
[[ "$(readlink "$stage/airootfs/etc/systemd/system/ModemManager.service")" == "/dev/null" ]]
[[ ! -L "$stage/airootfs/etc/systemd/system/dbus-org.freedesktop.ModemManager1.service" ]]
[[ -L "$wants/sshd.service" && -L "$wants/ModemManager.service" ]]

[[ "$(grep -xc 'bluez' "$stage/packages.x86_64")" -eq 1 ]]
for pkg in bluez-utils powertop wireguard-tools intel-ucode; do
  grep -Fxq "$pkg" "$stage/packages.x86_64"
done
bash -c '
  set -euo pipefail
  declare -A file_permissions=()
  source "$1/profiledef.sh"
  [[ "$iso_name" == "nemesis-air" ]]
  [[ "$iso_label" == NEMAIR_* ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-field-check]:-}" == "0:0:755" ]]
  [[ "${file_permissions[/usr/local/bin/nemesis-hw-report]:-}" == "0:0:755" ]]
' _ "$stage"

# Never silently replace preexisting staging; bootstrap must fail closed.
if ARCHISO_RELENG_PROFILE="$fixture" bash "$root/scripts/prepare-air-field-profile.sh" "$stage" >/dev/null 2>&1; then
  printf 'ERROR: overwrote existing Air staging\n' >&2
  exit 1
fi
printf 'MacBook Air optional profile staging fixture: PASS\n'
