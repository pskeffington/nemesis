# MacBook Operator package and toolkit literature matrix

**Reviewed:** 2026-11-20. **Edition:** `mac-intel-operator` for older non-T2 Intel MacBooks, with MacBookAir7,2 and 6,x first. This is an **engineering source review**, not measured battery, ISO size, or real laptop compatibility. A later thick MacBook Pro variant may reuse the same policy after independent hardware gates.

## Research method and rule

Official [ArchISO documentation](https://wiki.archlinux.org/title/Archiso) establishes the difference between full **releng** and truly minimal **baseline** profiles. Nemesis currently copies releng for known recovery behavior. Arch `plasma-desktop` already depends on `plasma-workspace`; avoid listing the latter explicitly as if it adds new capability. [Arch package dependencies](https://archlinux.org/packages/extra/x86_64/plasma-desktop/), [pacman package reasons](https://wiki.archlinux.org/title/Pacman) and [size/accounting guidance](https://wiki.archlinux.org/title/pacman/Tips_and_tricks) should drive decisions, not counts of manifest lines.

**Decision threshold:** preload if useful to every ordinary operator on the first boot, already signed in official Arch, safe by default, and affordable on a 4-GiB MacBook. Otherwise provide a curated opt-in toolkit; do not autostart radio, GPS, network scans, VPN, SSH or file transfer daemons. `nemesis-kit` is only a package selector; a persistent-system installer has **not** been implemented or validated.

| ID | Package / group | First-use operator task | Current disposition | Cost / dependency or security fact | Primary evidence |
| --- | --- | --- | --- | --- | --- |
| OPM-01 | `plasma-desktop` | Usable GUI, panel and settings | **Core** | 80 declared dependencies; already pulls `plasma-workspace`; no `plasma-meta` | [Arch](https://archlinux.org/packages/extra/x86_64/plasma-desktop/) |
| OPM-02 | `sddm`, `konsole`, `dolphin` | Session, terminal, files | **Core** | Real login and file access; avoid adding complete KDE application group | [Arch SDDM](https://archlinux.org/packages/extra/x86_64/sddm/), [Konsole](https://archlinux.org/packages/extra/x86_64/konsole/), [Dolphin](https://archlinux.org/packages/extra/x86_64/dolphin/) |
| OPM-03 | `kate` | Edit scripts and configuration | **Core, review later** | Package installed size reported ~36 MB; easier first-use editor | [Arch](https://archlinux.org/packages/extra/x86_64/kate/) |
| OPM-04 | `webkitgtk-6.0`, `gtk4`, `gtk4-layer-shell` | Display `globe.airplanes.live` behind KDE | **Core** | WebKitGTK package itself ~131-139 MB installed depending revision; native Rust program needs this engine | [Arch WebKitGTK](https://archlinux.org/packages/extra/x86_64/webkitgtk-6.0/), [upstream renderer](https://github.com/pskeffington/linux_live_wallpaper) |
| OPM-05 | `firefox` | Interactive globe and general web access | **Core, high footprint** | ~302 MB installed for browser package alone; duplicates some WebKit *capability* but supplies ordinary tabbed browsing. Re-evaluate if 4-GiB runtime fails | [Arch](https://archlinux.org/packages/extra/x86_64/firefox/) |
| OPM-06 | `networkmanager`, `plasma-nm` | Connect wireless/USB network fallback | **Core** | Use one network manager on Operator; remove inherited `iwd` / networkd enablement links only in Operator stage. Driver support still depends on exact PCI ID | [ArchWiki](https://wiki.archlinux.org/title/NetworkManager) |
| OPM-07 | `plasma-pa`, `xdg-desktop-portal-kde` | Standard media and desktop permissions | **Core** | KDE integration without broad KDE meta suite | [Arch plasma-pa](https://archlinux.org/packages/extra/x86_64/plasma-pa/), [portal](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-kde/) |
| OPM-08 | `wayland-utils`, `curl`, `noto-fonts`, `noto-fonts-emoji` | Layer-shell preflight, connectivity fallback and legibility | **Core** | `wayland-info` checks compositor protocol before wallpaper starts; tests of actual KDE placement still pending | [Arch Wayland utilities](https://archlinux.org/packages/extra/x86_64/wayland-utils/) |
| OPM-09 | `rtl-sdr` | Verify an inexpensive ADS-B receiver | **Core** | Light command-line/device utility; no automatic capture | [Arch](https://archlinux.org/packages/extra/x86_64/rtl-sdr/) |
| OPM-10 | `airspy` | Detect existing Airspy receiver | **Core** | Official package ~188 KB installed, not a heavy SDR GUI | [Arch](https://archlinux.org/packages/extra/x86_64/airspy/) |
| OPM-11 | `dump1090_rs` | Manual ADS-B decoder | **Core** | Program ~1.1 MB installed, but requires SoapySDR; receiver hardware and actual live decode untested | [Arch](https://archlinux.org/packages/extra/x86_64/dump1090_rs/) |
| OPM-12 | `usbutils`, `pciutils`, `jq` | Identify PCI/USB network/RF devices, inspect JSON | **Core** | Read-only inspection by default; don't publish device identifiers from actual machines | [Arch USB](https://archlinux.org/packages/core/x86_64/usbutils/), [Arch jq](https://archlinux.org/packages/extra/x86_64/jq/) |
| OPM-13 | `git`, `htop`, `tmux`, `wireguard-tools` | Acquire reviewed configs, inspect resources, preserve terminal state, prepare VPN | **Core** | No tunnels/credentials by default; operator manually enables WireGuard if installed | [Arch WireGuard](https://archlinux.org/packages/extra/x86_64/wireguard-tools/), [ArchWiki WireGuard](https://wiki.archlinux.org/title/WireGuard) |
| OPM-14 | `soapyrtlsdr`, `rtl_433` | ISM/RTL extensions | **Kit: aviation** | SDR plugins and ISM decoders unnecessary to the basic globe session | [RTL-433](https://archlinux.org/packages/extra/x86_64/rtl_433/), [SoapyRTLSDR](https://archlinux.org/packages/extra/x86_64/soapyrtlsdr/) |
| OPM-15 | `soapyairspy` | Use Airspy through the Soapy API | **Kit: airspy** | Small plugin; selected only when Soapy applications are used | [Arch](https://archlinux.org/packages/extra/x86_64/soapyairspy/) |
| OPM-16 | `gpsd`, `python-pyserial` | GNSS/serial receiver support | **Kit: gnss** | Do not run receiver daemons or collect location at boot | [Arch gpsd](https://archlinux.org/packages/extra/x86_64/gpsd/), [Arch pyserial](https://archlinux.org/packages/extra/any/python-pyserial/) |
| OPM-17 | `nmap`, `tcpdump`, `mtr`, `traceroute` | Authorized deeper network diagnostics | **Kit: network** | No automatic scans/captures; explicit root/capability policy per task | [Arch Nmap](https://archlinux.org/packages/extra/x86_64/nmap/), [Arch tcpdump](https://archlinux.org/packages/core/x86_64/tcpdump/) |
| OPM-18 | `gqrx` | Visual SDR tuning | **Kit: rf-lab** | The app itself ~1.6 MB installed but pulls **GNU Radio and gnuradio-osmosdr**. Transitive closure and RAM overhead, not app package bytes, determine heaviness | [Arch](https://archlinux.org/packages/extra/x86_64/gqrx/), [GNU Radio](https://archlinux.org/packages/extra/x86_64/gnuradio/) |
| OPM-19 | `base-devel`, `rust`, `python`, `python-pip`, `shellcheck` | Build and investigate source | **Kit: development** | Compiler ecosystems are not a dependency of running already-built Rust wallpaper | [Arch Base-devel](https://archlinux.org/groups/x86_64/base-devel/), [Rust](https://archlinux.org/packages/extra/x86_64/rust/) |
| OPM-20 | `qgis` | Field geospatial research | **Kit: gis** | Large graphical GIS/dependency closure; not a requirement for an online aircraft globe | [Arch](https://archlinux.org/packages/extra/x86_64/qgis/) |
| OPM-21 | `tar1090` / local ADS-B frontend | Optional local maps instead of public feed | **Deferred integration** | Not in official core manifest; license/data pipeline and user feeder credentials need a separate source review | [tar1090](https://github.com/wiedehopf/tar1090) |
| OPM-22 | Broadcom `wl` / custom Wi-Fi firmware | Internal MacBook Wi-Fi | **Device-specific only** | Never auto-select from model year or redistribute firmware; USB networking recovery remains mandatory | [Arch Broadcom](https://wiki.archlinux.org/title/Broadcom_wireless) |
| OPM-23 | SDRconnect / vendor binaries / custom Meshtastic build | Advanced radio integration | **Never unreviewed default** | Source, redistribution license, signed packages, USB safety and firmware policy must be separately approved | [Airspy](https://airspy.com/), [Meshtastic docs](https://meshtastic.org/docs/) |

## Hidden size cost in the upstream ArchISO profile

The previous Operator ISO compiled successfully at **approximately 2.3 GiB** on source `42fec1b7`; the final verifier exited on invalid `xorriso -find … -print` syntax despite a successful image and checksum. See [run 44735263256](https://github.com/pskeffington/nemesis/actions/runs/44735263256). This is a build **not payload-accepted**, and **not boot-tested**.

The official [ArchISO releng package list](https://github.com/archlinux/archiso/blob/master/configs/releng/packages.x86_64) includes `nmap`, `tcpdump`, `irssi`, VPN clients and virtual-machine guest packages **even when Nemesis core manifests do not**. Therefore merely deleting a package from Nemesis's added list does not remove it from the built ISO. A reviewed Operator-only `releng-drop.packages.x86_64` explicitly excludes such nonessentials; this never changes rescue or lean-Air profiles. It preserves `archinstall`, microcode, `linux-firmware`, USB recovery, `wpa_supplicant` and the signed boot path. If dependencies reintroduce a package, record that as a transitive dependency rather than hiding it.

**Do not sum direct package installed-size fields to predict ISO size.** Installed-size numbers above refer to *individual* Arch package metadata, not the unique dependency closure and not compressed SquashFS size. Compare source-locked ISOs by exact size, hash, same ArchISO/releng version, package inventory and full rootfs receipt before declaring a reduction.

## Hardware-aware user experience

- **First boot:** KDE, live aircraft map, browser and terminal, basic ADS-B hardware utilities, offline readiness and network fallback. No popup wizard requiring arbitrary package choices.
- **First install:** future authenticated installer must provision normal accounts, encryption and recoverability; it is NOT implemented. Live-ISO `operator` has no sudo.
- **Customization:** after installation, run `nemesis-kit list` and `nemesis-kit show aviation`; only the authenticated root user may deliberately run `nemesis-kit install KIT`. Uses pacman `-Syu --needed`, no AUR or background downloads.
- **4 GiB gate:** measure baseline after login with globe visible, then after opening browser, then after attaching an RTL-SDR. Report `MemAvailable`, CPU, GPU, battery, USB resets and idle/wake stability. Do not invent a battery duration or claim a package count equals RAM use.
- **MacBook Pro (older/thicker) lane:** may carry more memory but shares network/EFI/USB uncertainties. No extrapolated kernel, firmware or sleep PASS.

## Next gates

| ID | Decision | Evidence | Status |
| --- | --- | --- | --- |
| OP-P01 | Source tiering, official source matrix and removable-manifest check | This document, `spec/operator-kits.json`, Python/fixture/native Arch checks | IN REVIEW |
| OP-P02 | Signed repository availability across all kits | Native Arch `pacman -Si` read-only resolver in CI | NOT YET ACCEPTED |
| OP-P03 | Rebuilt lean Operator ISO and actual SquashFS with map and kits | `mkarchiso`, checksums, UEFI, xorriso and unsquashfs hashes | NOT YET ACCEPTED |
| OP-P04 | Persistent install customizer and authentication | Separate installer design and explicit physical/VM authorization | DEFERRED |
| OP-P05 | Runtime efficiency on MacBook Air 4 GiB / supported MacBook Pro | Measured before/after data on exact hardware, no secrets | DEFERRED |

Only after accepting OP-P03 should the exact size reduction be claimed. Source tests do not establish working KDE wallpaper or Mac hardware compatibility.

## Cross-distribution evidence — SigintOS, DragonOS, Skywave, Pentoo (2026-11-20)

The detailed [SIGINT/SDR OS deployment matrix](SIGINT_OS_PACKAGE_DEPLOYMENT_MATRIX.md) and [machine-readable publisher inventory](../../spec/sigint-distro-references.json) compare the **advertised tool stacks** and modular distribution patterns of SigintOS 2.0 Community Edition, DragonOS Resolute R2.2 (2026-10-27), Skywave Linux 5.10.0 and Gentoo-based Pentoo. DragonOS's listed ~4.0-GB ISO demonstrates an all-in-one capability path, **not** a like-for-like size comparator with Nemesis's prior ~2.3-GiB image. Pentoo's meta/profile/USE-flag selection is an architectural model, not a compatible Arch package source. Keep current seven Operator kits unchanged until actual Arch dependency, license, service and hardware evidence justifies additions. **No binary, firmware, service or default package was imported from these distributions.**
