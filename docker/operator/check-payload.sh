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
xorriso -indev "$iso" -find /arch/x86_64/airootfs.sfs -print \
  > "$evidence/iso-rootfs-entry.txt" 2>&1 || die "ISO rootfs missing"
grep -Fq /arch/x86_64/airootfs.sfs "$evidence/iso-rootfs-entry.txt" || die "rootfs entry absent"
unsquashfs -ll "$sfs" usr/local/bin etc/xdg/autostart etc/systemd/system \
  usr/lib/sysusers.d usr/lib/tmpfiles.d usr/bin > "$evidence/operator-payload.txt" || die "rootfs inventory failed"
for target in usr/local/bin/linux-live-wallpaper \
              usr/local/bin/nemesis-operator-wallpaper \
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
# Brand images are optional: on branded dispatches, inspect the actual
# assembled rootfs and compare every installed object to its source master.
if [[ "${NEMESIS_OPERATOR_BRAND:-0}" == 1 ]]; then
  for pair in \
    "brand/theme/kde/Nemesis.colors:usr/share/color-schemes/Nemesis.colors" \
    "brand/plasmoid/org.nemesis.themecontrols/metadata.json:usr/share/plasma/plasmoids/org.nemesis.themecontrols/metadata.json" \
    "brand/plasmoid/org.nemesis.themecontrols/contents/ui/ModeBoard.qml:usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/ui/ModeBoard.qml" \
    "brand/plasmoid/org.nemesis.themecontrols/contents/ui/IconTile.qml:usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/ui/IconTile.qml" \
    "brand/plasmoid/org.nemesis.themecontrols/contents/ui/main.qml:usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/ui/main.qml"; do
    src="${pair%%:*}"
    target="${pair#*:}"
    unsquashfs -cat "$sfs" "$target" | cmp -s "$root/$src" - || die "built theme object mismatch: $target"
  done
  for icon in terminal radio database location drone satellite headphones shield; do
    for target in "usr/share/icons/hicolor/scalable/apps/nemesis-$icon.svg" \
      "usr/share/plasma/plasmoids/org.nemesis.themecontrols/contents/images/$icon.svg"; do
      unsquashfs -cat "$sfs" "$target" | cmp -s "$root/brand/icons/$icon.svg" - || die "built icon mismatch: $target"
    done
  done
  printf 'brand_payload=CANONICAL_OBJECTS_VERIFIED_NOT_RENDERED\n' >> "$evidence/provenance.txt"
else
  if unsquashfs -ll "$sfs" usr/share/plasma/plasmoids/org.nemesis.themecontrols 2>/dev/null | grep -Fq 'org.nemesis.themecontrols'; then
    die "unrequested brand applet leaked into default Operator rootfs"
  fi
fi
printf 'Operator SquashFS payload integrity and autostart contracts: PASS (not boot evidence)\n'
