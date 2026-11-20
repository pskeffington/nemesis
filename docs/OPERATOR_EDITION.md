# Nemesis Operator — live aviation desktop

**Scope:** a separate x86_64 non-T2 Intel Mac field-operator ISO, prioritizing MacBookAir7,2 and 6,x. The generic `mac-intel` rescue and lean `macbook-air-field` images remain independent. This source and its Docker build are not evidence of an operating Plasma session or physical Mac compatibility.

## Desktop experience

1. Boot the Operator ISO to KDE Plasma **Wayland** through SDDM. A nonprivileged, password-locked live-only `operator` user is configured for autologin; this is **not** an installed-machine account policy. Since that disposable account has no usable password, the Operator **live image only** disables KDE automatic locking and password-on-unlock in `/etc/xdg/kscreenlockerrc` to prevent accidental lockout. This is **not a secure installed-session configuration** and must never be inherited by a later persistent installation.
2. KDE's **XDG autostart** launches `/usr/local/bin/nemesis-operator-wallpaper` once a graphical session exists. This avoids relying on an unverified systemd-user session enablement mechanism.
3. The wrapper checks `XDG_SESSION_TYPE`, `WAYLAND_DISPLAY`, and the compositor's `zwlr_layer_shell_v1` support. Unsupported sessions retain the regular KDE background rather than crashing or covering desktop controls.
4. With protocol support, the first-party `linux-live-wallpaper` renderer starts in background mode with **https://globe.airplanes.live/** as its default live aircraft map. Click-through mode leaves KDE windows, panels and other controls usable. For direct map interaction, the operator can use a normal browser session.
5. An original locally bundled `offline.html` standby page displays on connectivity failure. The wrapper retries the remote source every 180 seconds; it does not present invented or stale aircraft positions as live data.
6. No GPS location, hidden website credentials, custom scraping, map mirroring, self-signed TLS exceptions or remote-control permissions are configured.

## Lightweight first-use core and optional kits

The separate Operator image prioritizes **a complete working desktop** over a preinstalled specialist workstation. Its default manifests include KDE Plasma/SDDM, the user-owned WebKitGTK globe renderer, Firefox for interactive map use, Konsole, Dolphin, Kate, a single NetworkManager backend, USB/PCI inspection, Airspy and RTL-SDR hardware utilities, basic `dump1090_rs` ADS-B decoding, `jq`, `tmux`, `htop`, `git` and WireGuard client tools. No receiver capture, network scan, GPS logging or remote login starts automatically.

| Optional kit | Signed Arch packages | Intended operator |
| --- | --- | --- |
| `aviation` | `soapyrtlsdr`, `rtl_433` | RTL-SDR/ISM receiver expansion |
| `airspy` | `soapyairspy` | Airspy in a Soapy application |
| `gnss` | `gpsd`, `python-pyserial` | Attached GNSS devices |
| `network` | `nmap`, `tcpdump`, `mtr`, `traceroute` | Approved advanced network diagnostics |
| `rf-lab` | `gqrx` (GNU Radio dependency closure) | Spectrum GUI work |
| `development` | `base-devel`, `rust`, `python`, `python-pip`, `shellcheck` | Compiling/debugging tools |
| `gis` | `qgis` | GIS and research cartography |

The original `releng` ArchISO package list also contains `nmap`, `tcpdump` and other nonessential rescue utilities. The **Operator staged copy only** uses a reviewed [exclusion manifest](../profiles/mac-intel-operator/releng-drop.packages.x86_64), preserving boot, firmware, `archinstall` and recovery. The plain rescue and lean Air images are unchanged. The current source-level package matrix and quantitative uncertainty are documented in [OPERATOR_PACKAGE_LIT_MATRIX.md](research/OPERATOR_PACKAGE_LIT_MATRIX.md).

**Live media:** `nemesis-kit list` or `nemesis-kit show rf-lab` works without root or network; no package installation is permitted. **Installed system:** a future authorized installer must establish real user/root authentication, then the administrator may explicitly run `nemesis-kit install KIT` (interactive official pacman `-Syu --needed`, no automatic AUR or sudo escalation). This **does not mean Nemesis already has an installable persistent OS**; installer acceptance is a separate future gate.

The previous full Operator image was ~2.3 GiB with ISO checksum success, but its rootfs verifier failed; the revised lean image size is **not measured yet**. Avoid summing direct Arch package sizes as if they were compressed ISO savings. KDE/WebKit/browser remain fixed costs because the map desktop is non-negotiable.

## Source provenance

The user's own [linux_live_wallpaper](https://github.com/pskeffington/linux_live_wallpaper) program has an MIT license, a committed `Cargo.lock`, a `--background` CLI flag, and a GTK4/WebKitGTK6 layer-shell backend. Its source is pinned to immutable commit `ee51045dc394f73d8151906fe9f397dd3cc94060`. The build script fetches only that revision and builds `cargo build --release --locked` **as a non-root process** in an ephemeral GitHub runner. The compiled binary and exact source/lockfile hashes are recorded and staged separately into the Operator image.

The third-party [Airplanes.live Globe](https://globe.airplanes.live/) URL is linked and shown directly in WebKit. Its live content, branding, services and terms remain controlled by the website operator. Nemesis does **not** redistribute map tiles or live aircraft data; the offline design is original and contains no positions.

## Boot and network boundaries

The live-only SDDM user has no wheel/sudo credentials and no persistent profile secrets. Optional kit manifests are available to read, but cannot be installed on this live account. **Do not replicate autologin** into a later installed laptop without new authentication and encryption controls. Operator starts `NetworkManager` to work with Plasma's network applet and removes **only its own staging copy** of inherited Air iwd/systemd-networkd enablement links. It retains the Air profile's masked ModemManager and disabled sshd auto-start. The original Air and rescue ISO configurations are unchanged.

No Broadcom proprietary driver, automatic VPN, RF capture, USB autosuspend override, fan override or power tuning is introduced. An online globe draws battery/GPU resources: real idle memory and power impact on 4 GiB MacBook Air models are **unmeasured**.

## Acceptance levels

- **OP-01:** GitHub Python contract, ShellCheck, fixture staging, packaged ArchISO staging, user/boot/network configuration source checks.
- **OP-02:** Compiled pinned MIT binary with checksum, official-signed Arch package resolution, real separate `mkarchiso`, SHA-256 sidecar, UEFI El Torito inspection and built SquashFS payload verification.
- **OP-03 (not yet authorized):** virtual KDE Wayland boot, login, background layering, reboot auto-start, normal input, site rendering, offline-to-online fallback and source provider permission checks.
- **OP-04 (future physical Mac):** battery/thermal/4 GiB memory, internal Broadcom Wi-Fi/USB networking, receiver USB stability, sleep/wake and recovery. No accepted hardware evidence exists.

**Critical distinction:** a successful ISO checksum does **not** prove a graphical session or functioning live wallpaper.

## Theme composition

The live map is the central desktop visual. Design Nemesis translucent panels, icons, alerts and original offline elements around it; protect accessibility and legibility. Reuse independently reviewed assets from [theme PR #5](https://github.com/pskeffington/nemesis/pull/5) only after checking license and KDE runtime layering. Do not copy airplanes.live artwork or pretend its live data is locally generated.

**Repository sources:** [Operator contract](../spec/operator-edition.json), [Operator Codex passes](../codex/OPERATOR_PASS.md), [Docker workflow](../.github/workflows/docker-operator.yml), [upstream wallpaper app](https://github.com/pskeffington/linux_live_wallpaper).

## Initial source and binary compile evidence (2026-11-20)

[Main merge e36930c](https://github.com/pskeffington/nemesis/commit/e36930c79a5f80c36dc200fcc473d0a9d1be355d) passed [source contract 44734587975](https://github.com/pskeffington/nemesis/actions/runs/44734587975) and [signed native ArchISO staging 44734587794](https://github.com/pskeffington/nemesis/actions/runs/44734587794). [Operator Docker 44734587874](https://github.com/pskeffington/nemesis/actions/runs/44734587874) assembled the signed toolchain image and successfully compiled `linux_live_wallpaper` as a non-root user at the pinned SHA. **Operator ISO mkarchiso, filesystem payload, auto-start after reboot and actual Plasma rendering remain separate unaccepted gates** at the time of this evidence entry. Follow [issue #19](https://github.com/pskeffington/nemesis/issues/19) for stage-specific acceptance.
