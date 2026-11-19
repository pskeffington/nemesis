# MacBook Air wireless driver decision matrix — network-first field reliability

**Research date:** 2026-11-19. **Platforms:** pre-T2 MacBookAir5,x / 6,x / 7,x. This is an engineering choice record, **not** a driver installer, hardware certificate, or authorization to fetch firmware.

## Why first-boot networking is a separate gate

Intel MacBook Airs in this cohort often lack built-in Ethernet, and community reports document Broadcom Wi-Fi that does not function from a stock live environment. Losing internal WLAN must never prevent local recovery, diagnostics, or evidence capture. An operator should bring a **verified USB Ethernet, USB wireless or USB phone-tether option** before testing.

| Candidate path | Evidence | Practical advantage | Restriction and release decision |
| --- | --- | --- | --- |
| Stock in-kernel driver / packaged firmware | [ArchWiki Mac troubleshooting](https://wiki.archlinux.org/title/Mac/Troubleshooting), S2; [Linux Wireless](https://wireless.docs.kernel.org/en/latest/en/users/drivers/brcm80211.html), S1 | Signed Arch packages and normal kernel maintenance | First inspect precise PCI ID/driver; `brcmfmac`/`b43` may **not** support the BCM4360 case; do not silently force |
| Broadcom `wl` / `broadcom-wl-dkms` | [ArchWiki Broadcom wireless](https://wiki.archlinux.org/title/Broadcom_wireless), S2; [Air7,2 report](https://github.com/AdhamNasr/MacBookAir-ArchLinux-i3), S3 | Common documented path for BCM4360 Air 6,x/7,x | Proprietary and out-of-tree DKMS/module maintenance; **not** pre-bundled in Nemesis. Requires package/source license and kernel update/recovery review |
| Experimental BCM4360 reimplementation | [xZinio/bcm4360](https://github.com/xZinio/bcm4360), S3; inspected main `47191ae1b509a5a4ba28923556d1de7bd6be681f` | Describes DKMS `bcm4360` and `bcm4360_open` options and reports one Air7,2 test | GPL-2.0 code claims still depend on Broadcom microcode/data obtained at install; source is **experimental**, not upstream-reviewed as production-ready. No auto install or firmware redistribution approval |
| USB tether / USB Ethernet / known in-kernel USB Wi-Fi device | [ArchWiki Mac](https://wiki.archlinux.org/title/Mac), S2; [Air6,2 Debian](https://wiki.debian.org/InstallingDebianOn/Apple/MacBookAir/6-2), S2 | Enables signed-package rescue and diagnostics when internal WLAN fails | Operator must validate exact adapter VID:PID, firmware, USB power and reconnect before relying on field use |

## Mandatory decision sequence

1. Determine real Mac model and T2/architecture lane; reject ARM and T2 from the generic Intel Air profile.
2. Capture only sanitized `lspci -nnd ::0280` vendor/device IDs, current kernel and active driver. Do not publish serial, SSID, MAC, IP, VPN keys or raw logs.
3. Test an already-signed in-kernel driver where hardware support is documented. Never blacklist competing modules globally before an operator-confirmed recovery path.
4. Verify the USB network fallback **with all internal WLAN disabled**; store no private Wi-Fi configuration in the ISO.
5. If proprietary/out-of-tree code is essential, demand a security- and license-reviewed, kernel-version-specific package source. A third-party git repo or AUR instructions are **not** signed-release permission.
6. Before approving a default driver, document reboot/recovery, 10 reconnections across supported frequency bands, suspend/wake stability, VPN IPv4/IPv6 and DNS-leak checks, and kernel-update regression risk.
7. If an adapter or driver fails, keep device status PARTIAL/FAIL and leave the source build offline-capable; do not mark a generic model PASS.

## Current Nemesis implementation

- `profiles/macbook-air-field/packages.x86_64` intentionally includes **no Broadcom driver**, out-of-tree kernel, automatic module blacklist or firmware fetcher.
- `nemesis-field-check` reports PCI wireless IDs and NetworkManager state without changing radio switches, credentials or services.
- `spec/macbook-air-field.json` requires PCI-ID selection and a USB-network contingency. This is source configuration, **not verified Wi-Fi connectivity**.
- MacBookAir7,2 and 6,2 are first model candidates because this wireless risk is material to field viability.

This Wi-Fi gate is a **P0 blocker for field deployments that require internal wireless connectivity**. It is not a blocker to offline diagnostics, external-USB network rescue, or a source-only Docker build.
