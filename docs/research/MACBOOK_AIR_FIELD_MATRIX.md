# F03-A — MacBook Air field engineering literature matrix

**Reviewed:** 2026-11-19. These are source findings for engineering, not Nemesis physical-test results.

| ID | Topic | Source and evidence tier | Engineering finding | Nemesis decision | Future observable gate |
| --- | --- | --- | --- | --- | --- |
| MBA-01 | Air device coverage | [ArchWiki Laptop/Apple](https://wiki.archlinux.org/title/Laptop/Apple), community S2 | Historic Air 5,2, 6,x and 7,2 reports differ in wireless, camera and sleep | Prioritize Air7,2/6,2 then smaller Air/older units; no blanket model-year support | Actual boot, input, Wi-Fi and resume |
| MBA-02 | Air6,2 | [Debian Air6,2](https://wiki.debian.org/InstallingDebianOn/Apple/MacBookAir/6-2), community S2 | Intel HD 5000 and BCM4360 reported; wireless may be nonfunctional out of box | Carry USB Ethernet/tether recovery before first Wi-Fi setup | PCI ID, USB network, local shell |
| MBA-03 | Air7,2 | [Air7,2 Arch instructions](https://github.com/AdhamNasr/MacBookAir-ArchLinux-i3), individual S3 | 4 GiB configuration, HD 6000, BCM4360, trackpad, camera and suspend reports | Protect low-RAM path and treat camera/driver as optional | Model-specific device and RAM evidence |
| MBA-04 | Broadcom | [ArchWiki Mac troubleshooting](https://wiki.archlinux.org/title/Mac/Troubleshooting), S2 | Mac Wi-Fi chips require different drivers; some use proprietary out-of-tree `wl` | No auto `broadcom-wl`, no default blacklist; identify PCI ID and trusted package origin | Kernel/driver lifecycle and reconnection tests |
| MBA-05 | Power managers | [ArchWiki Power management](https://wiki.archlinux.org/title/Power_management), S2 | Overlapping tools and blanket runtime power management can break devices | Leave power manager selection unconfigured | Idle/load battery and input tests |
| MBA-06 | USB autosuspend | [ArchWiki TLP](https://wiki.archlinux.org/title/TLP), S2 | Autosuspend can disrupt USB audio/devices; tuning must be per known device | Preserve upstream; no default TLP or aggressive USB policies | 30-minute SDR receive and USB reset audit |
| MBA-07 | WLAN backend | [ArchWiki NetworkManager](https://wiki.archlinux.org/title/NetworkManager), S2 | NM may manage iwd; manually enabling iwd concurrently is incorrect | Preserve current backend, no credential provisioning | Wireless and VPN IPv4/IPv6 checks |
| MBA-08 | Field ISO size | [ArchISO](https://wiki.archlinux.org/title/archiso), upstream S1/S2 | `releng` is full install/rescue and `baseline` minimal | Evaluate distinct lean field profile, not rescue-image feature removal | A/B image hashes, RAM and boot |
| MBA-09 | Older Air5,x | [ArchWiki Laptop/Apple](https://wiki.archlinux.org/title/Laptop/Apple), S2 | Air5,2 Wi-Fi speed may require third-party wl; Air5,1 trackpad/sleep issues reported | Legacy regression tier, not universal driver tuning | Wi-Fi driver and resume logs |
| MBA-10 | Other Mac platforms | [t2linux](https://wiki.t2linux.org/state/) and [Asahi](https://asahilinux.org/docs/), S1/S2 | T2 and ARM64 require distinct boot/driver paths | Keep separate editions; never merge into Intel non-T2 Air field overlay | Own platform feasibility and hardware gates |

**Hardware evidence must state** NOT TESTED, PARTIAL, FAIL or PASS with ISO SHA, date, exact model, relevant PCI IDs, kernel/version, and redacted observations. Currently all MacBook Air physical outcomes are **NOT TESTED**. The 1.3-GB Docker ISO result belongs to the generic Intel image, not this field variant.

Follow the source fixture in [field specification](../../spec/macbook-air-field.json), the [field runbook](../../codex/MACBOOK_AIR_FIELD_PASS.md), and [architecture](../FIELD_LAPTOP_ARCHITECTURE.md).

## MAC-A11 — Inherited live-image service policy

[ArchISO upstream releng systemd target wants](https://github.com/archlinux/archiso/tree/master/configs/releng/airootfs/etc/systemd/system/multi-user.target.wants) (S1) includes `sshd.service`, `ModemManager.service`, `iwd.service`, and `systemd-networkd.service` symlinks in the inspected upstream configuration. **Nemesis decision:** on the MacBook Air *field* staging image, remove only the first two enablement symlinks, leaving its upstream networking and the generic Intel rescue edition unchanged. The user still must validate hardware Wi-Fi and USB communications on physical devices. Static proof: `tests/test-air-profile.sh` and `tests/test-installed-air-profile.sh`.
