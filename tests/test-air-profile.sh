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
mkdir -p "$fixture/airootfs"
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
