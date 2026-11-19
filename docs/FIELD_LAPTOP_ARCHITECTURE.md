# Nemesis — MacBook Air field-laptop architecture

**Mode:** GitHub repository preparation, 2026-11-19. The existing Intel rescue ISO assembled and passed SHA/EFI-metadata checks in [Docker CI 44610122687](https://github.com/pskeffington/nemesis/actions/runs/44610122687). **The optional Air layer now has an independently selected ArchISO profile and builder.** Its Docker image result and physical boot/compatibility are pending separate acceptance gates; generic Intel rescue ISO is unchanged.

## First deployment targets
- **P0:** MacBookAir7,2 (2015/2017 13-inch), then MacBookAir6,2 (2013–2014 13-inch) and 6,1 (11-inch)
- **P1:** MacBookAir7,1 (2015 11-inch), MacBookAir5,2 and 5,1 (2012)
- **Separate platforms:** T2-equipped Intel Air generations and all Apple Silicon Air models

Model IDs, chipset IDs, boot firmware and recovery pathways must be verified on actual devices. The early generations are 64-bit Intel EFI *candidates*, not certified support.

## Field operating priorities

| Rank | System area | Optimization decision | Acceptance criterion |
| --- | --- | --- | --- |
| P0 | EFI and recovery | Preserve the existing ArchISO rescue baseline and macOS recovery; never auto-write internal storage | External boot and verified return to macOS |
| P0 | Offline communications | Internal Broadcom WLAN is optional at first boot; plan USB Ethernet, USB Wi-Fi or phone tether fallback | Usable shell and local recovery with no Internet |
| P0 | Battery and charging | Report battery/AC state; do not assume remaining battery health or automate discharge tuning | Measured battery health and AC/battery readings |
| P0 | Thermals and fan safety | Observe sensor data; no automatic `mbpfan`, `macfand` or unsafe CPU/fan caps | Sensor temperature and stability under supervised load |
| P0 | Input and display | Verify internal keyboard, trackpad, brightness and external USB input before desktop effects | Usable console, keyboard, touchpad, screen |
| P1 | Suspended operation | Retain upstream policy until the model passes 10 controlled suspend/resume cycles | Zero failed resumes for tested hardware |
| P1 | SDR/USB stability | No automatic USB autosuspend changes; RF/GNSS packages remain optional | 30-minute receiver stream without resets |
| P1 | Secure data and VPN | Signed packages; encrypted installation only with explicit consent; no default SSH, tunnel, logging export | Offline records intact, recoverable, no leaked credentials |
| P2 | Desktop design | Test a lean accessible KDE configuration on actual 4-GiB-class Air hardware | Measured idle RAM/CPU, legible UI and captioning |
| P2 | Field software | Optional RF, mapping, transcription and engineering manifests after hardware | No unwanted package bloat in rescue base |

## Critical technical constraints

- Many Air 6,x/7,x examples have a Broadcom **BCM4360** card. Some rely on the proprietary/out-of-tree `wl` driver; it is **not bundled** without security, licensing and kernel lifecycle review. Record the exact PCI ID before driver decisions. An Air lacks a conventional built-in Ethernet port; always provision a USB connectivity fallback.
- The inherited ArchISO `releng` profile enables `iwd.service` and `systemd-networkd.service` by default. The optional field packages include NetworkManager tooling, but **do not automatically enable NetworkManager** or start a competing WLAN manager. Change backend only in a separately tested decision, and never preload personal Wi-Fi credentials.
- **One laptop power manager at a time:** TLP, power-profiles-daemon and tuned can conflict. No service is auto-enabled in the optional field layer. TLP USB autosuspend can disrupt USB equipment, especially receivers.
- The Air profile removes inherited `sshd.service` and `ModemManager.service` enablement symlinks **only in its staged copy** and masks `ModemManager.service` to stop D-Bus-triggered probing. SSH remains installed but not auto-enabled; intentionally re-enabling modem management requires a separate operator-approved profile. The generic rescue profile is untouched. The generic rescue profile remains unchanged.
- The radio operator stack must not automatically start SDR, upload signals, attach serial devices or mask logs; collection is a separately authorized user action.
- No APFS mounting, Mac firmware extraction, repartition, blanket graphics kernel parameters, or universal fan rules in the first live image.
- Actual battery-hour targets are not assigned until battery health, ambient temperature and workload are measured. A source pass cannot establish field runtime.

## Source architecture

- `spec/macbook-air-field.json`: six candidate models, ten physical acceptance gates, conservative power/network/security policy.
- `profiles/macbook-air-field/packages.x86_64`: four optional official-Arch package candidates (`bluez`, `bluez-utils`, `powertop`, `wireguard-tools`).
- `profiles/macbook-air-field/airootfs/usr/local/bin/nemesis-field-check`: read-only battery, charging, thermal, sleep, wireless PCI-ID and power-manager conflict observations. A fixture environment override supports CI testing.
- `tests/test_macbook_air_field.py` plus the existing foundation/static CI enforce separation.
- `spec/editions.json`: `macbook-air-field` is a separately selected **source-scaffold** with its own staging/build scripts; the generic `mac-intel` builder and manifest remain unchanged.

**Image-size baseline:** approximately 1.3 GB for the full `releng`-derived Intel ISO in Docker. ArchISO also has a small `baseline` profile. A future A/B study should compare rescue functions, bootability, image size, RAM footprint, power and recovery before adopting a smaller independent field profile. Never replace the validated rescue image simply to reduce size.

## Future MacBook Air acceptance (NOT TESTED)

1. Record model without serial, CPU, chipset PCI IDs, kernel, SHA and EFI mode; have a known-good USB adapter, keyboard, power and macOS recovery.
2. Check external EFI boot, console keyboard, trackpad and visual backlight.
3. Confirm internal Wi-Fi driver provenance, a working USB network fallback and ten successful network reconnections.
4. Measure battery idle/acquisition drain for a fixed interval, note battery health, fan and sensor behavior.
5. Supervise ten sleep/lid cycles, document any failed wake with safe rollback.
6. Run a USB SDR for at least 30 minutes and record receiver reset count and thermal effects.
7. Perform a disconnected offline workflow and check local evidence hashes and storage recovery.
8. Verify a return to macOS. Never publish raw serials, MACs, SSIDs, locations or captures.

The opt-in Air edition is now stageable with a separate image builder and has a source fixture test. A distinct GitHub Docker build is underway; its ISO, checksum and EFI-metadata acceptance must be observed before claiming image assembly. The existing rescue ISO, UEFI VM and Mac physical gates must remain distinct.

**Upstream:** [Apple laptop models](https://wiki.archlinux.org/title/Laptop/Apple); [Debian Air6,2](https://wiki.debian.org/InstallingDebianOn/Apple/MacBookAir/6-2); [Air7,2 Arch report](https://github.com/AdhamNasr/MacBookAir-ArchLinux-i3); [Power management](https://wiki.archlinux.org/title/Power_management); [TLP](https://wiki.archlinux.org/title/TLP); [ArchISO](https://wiki.archlinux.org/title/archiso).

## Field image payload evidence

The dedicated Docker verifier checks that the image references an `airootfs.sfs` payload and inspects the built SquashFS from the same `mkarchiso` run. This must show the read-only `nemesis-field-check`, preserved `iwd`/networkd service links, **no multi-user autoenable symlink** for SSH/ModemManager, and a `ModemManager.service` mask to `/dev/null`. This is a **build-content test**, not proof that systemd started correctly on a MacBook Air or that any Wi-Fi/SDR peripheral works.
