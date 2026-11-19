#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Fixture test: package deduplication, overlay, profile labels, no overwrite.
# ---------------------------------------------------------------------
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
fixture="$tmp/releng"
stage="$tmp/staged"
mkdir -p "$fixture/airootfs"

cat > "$fixture/profiledef.sh" <<'EOF'
#!/usr/bin/env bash
iso_name="archlinux"
iso_label="ARCH_TEST"
iso_publisher="Arch Linux"
iso_application="Arch live"
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)
EOF

cat > "$fixture/packages.x86_64" <<'EOF'
base
linux
linux-firmware
EOF

ARCHISO_RELENG_PROFILE="$fixture" bash "$root/scripts/prepare-profile.sh" mac-intel "$stage"
grep -Fxq 'iso_name="nemesis"' "$stage/profiledef.sh"
grep -Fq '["/usr/local/bin/nemesis-hw-report"]="0:0:755"' "$stage/profiledef.sh"
[[ -f "$stage/airootfs/usr/local/bin/nemesis-hw-report" ]]
[[ "$(grep -xc 'linux-firmware' "$stage/packages.x86_64")" -eq 1 ]]
grep -Fxq 'intel-ucode' "$stage/packages.x86_64"

# Fail rather than overwriting a previously staged profile.
if ARCHISO_RELENG_PROFILE="$fixture" bash "$root/scripts/prepare-profile.sh" mac-intel "$stage" >/dev/null 2>&1; then
  printf 'ERROR: existing destination was overwritten\n' >&2
  exit 1
fi

# Check that the generated profile can be sourced and has the intended name.
bash -c 'source "$1/profiledef.sh"; [[ "$iso_name" == "nemesis" && "$iso_label" == NEMESIS_* ]]' _ "$stage"
printf 'Fixture profile staging: passed\n'
