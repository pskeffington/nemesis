#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Inspect actual built SquashFS for pinned renderer, KDE auto-start and
# operator tools. No real Wayland/Plasma boot is inferred from file presence.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis operator payload: %s\n' "$*" >&2; exit 1; }
[[ "${NEMESIS_CI_DOCKER:-}" == 1 ]] || die "CI-only guard"
[[ $# -eq 2 ]] || die "usage: bash docker/operator/check-payload.sh ISO EVIDENCE"
iso="$1"
evidence="$2"
[[ -s "$iso" && -d "$evidence" ]] || die "missing built ISO or evidence directory"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sfs="$root/.build/work-mac-intel-operator/iso/arch/x86_64/airootfs.sfs"
[[ -s "$sfs" ]] || die "built operator SquashFS missing"
# Arch xorriso supports -lsd for a single ISO entry; the prior -find
# ... -print expression returned an error *after* a successful 2.3-GiB
# build/checksum. Reject genuinely absent paths, not unsupported syntax.
xorriso -indev "$iso" -lsd /arch/x86_64/airootfs.sfs \
  > "$evidence/iso-rootfs-entry.txt" 2>&1 || die "ISO rootfs lookup failed"
grep -Fq airootfs.sfs "$evidence/iso-rootfs-entry.txt" || die "rootfs entry absent"
unsquashfs -ll "$sfs" usr/local/bin usr/share/nemesis-operator/kits etc/xdg/autostart etc/systemd/system \
  usr/lib/sysusers.d usr/lib/tmpfiles.d usr/bin > "$evidence/operator-payload.txt" || die "rootfs inventory failed"
for target in usr/local/bin/linux-live-wallpaper \
              usr/local/bin/nemesis-operator-wallpaper \
              usr/local/bin/nemesis-kit \
              usr/share/nemesis-operator/kits/rf-lab.packages.x86_64 \
              etc/xdg/autostart/nemesis-operator-wallpaper.desktop \
              usr/bin/konsole usr/bin/sddm usr/bin/rtl_test \
              usr/lib/sysusers.d/nemesis-operator.conf; do
  grep -Fq "$target" "$evidence/operator-payload.txt" || die "missing built payload: $target"
done
autostart="$(unsquashfs -cat "$sfs" etc/xdg/autostart/nemesis-operator-wallpaper.desktop)"
[[ "$autostart" == *"OnlyShowIn=KDE;"* && "$autostart" == *"Exec=/usr/local/bin/nemesis-operator-wallpaper"* ]] || die "KDE autostart invalid"
runner="$(unsquashfs -cat "$sfs" usr/local/bin/nemesis-operator-wallpaper)"
[[ "$runner" == *"https://globe.airplanes.live/"* ]] || die "default map URL missing"
[[ "$runner" == *"file:///usr/share/nemesis-operator/offline.html"* ]] || die "offline fallback not configured"
[[ "$runner" == *"--background"* ]] || die "background mode not configured"
kitcli="$(unsquashfs -cat "$sfs" usr/local/bin/nemesis-kit)"
[[ "$kitcli" == *"pacman -Syu --needed"* ]] || die "interactive on-demand kit installer missing"
gnss_manifest="$(unsquashfs -cat "$sfs" usr/share/nemesis-operator/kits/gnss.packages.x86_64)"
[[ "$gnss_manifest" == *"gpsd"* ]] || die "GNSS toolkit manifest missing gpsd"
sddm="$(unsquashfs -cat "$sfs" etc/sddm.conf.d/10-nemesis-operator-live.conf)"
[[ "$sddm" == *"User=operator"* && "$sddm" == *"Session=plasma.desktop"* ]] || die "ephemeral session not configured"
locker="$(unsquashfs -cat "$sfs" etc/xdg/kscreenlockerrc)"
for flag in '[Daemon]' 'Autolock=false' 'LockOnResume=false' 'RequirePassword=false'; do
  [[ "$locker" == *"$flag"* ]] || die "live-only lock screen safeguard missing: $flag"
done
service="$evidence/operator-payload.txt"
grep -Fq "etc/systemd/system/default.target -> /usr/lib/systemd/system/graphical.target" "$service" || die "graphical default missing"
grep -Fq "etc/systemd/system/display-manager.service -> /usr/lib/systemd/system/sddm.service" "$service" || die "sddm link missing"
grep -Fq "multi-user.target.wants/NetworkManager.service" "$service" || die "NetworkManager not enabled"
if grep -Eq 'multi-user.target.wants/(sshd|ModemManager|iwd|systemd-networkd).service' "$service"; then
  die "unsafe or conflicting inherited service enabled"
fi
grep -Eq 'etc/systemd/system/ModemManager.service -> /dev/null' "$service" || die "ModemManager mask absent"
provenance="$(unsquashfs -cat "$sfs" usr/share/nemesis-operator/wallpaper-provenance.txt)"
expected="$(printf '%s\n' "$provenance" | sed -n 's/^binary_sha256=//p')"
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || die "wallpaper hash missing"
actual="$(unsquashfs -cat "$sfs" usr/local/bin/linux-live-wallpaper | sha256sum | awk '{print $1}')"
[[ "$expected" == "$actual" ]] || die "built wallpaper binary hash mismatch"
printf 'binary_sha256=%s\n' "$actual" > "$evidence/wallpaper-sha256.txt"
printf 'Operator SquashFS payload integrity and autostart contracts: PASS (not boot evidence)\n'
