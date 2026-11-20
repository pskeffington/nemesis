# Nemesis Operator — live aviation desktop

**Scope:** a separate x86_64 non-T2 Intel Mac field-operator ISO, prioritizing MacBookAir7,2 and 6,x. The generic `mac-intel` rescue and lean `macbook-air-field` images remain independent. This source and its Docker build are not evidence of an operating Plasma session or physical Mac compatibility.

## Desktop experience

1. Boot the Operator ISO to KDE Plasma **Wayland** through SDDM. A nonprivileged, password-locked live-only `operator` user is configured for autologin; this is **not** an installed-machine account policy.
2. KDE's **XDG autostart** launches `/usr/local/bin/nemesis-operator-wallpaper` once a graphical session exists. This avoids relying on an unverified systemd-user session enablement mechanism.
3. The wrapper checks `XDG_SESSION_TYPE`, `WAYLAND_DISPLAY`, and the compositor's `zwlr_layer_shell_v1` support. Unsupported sessions retain the regular KDE background rather than crashing or covering desktop controls.
4. With protocol support, the first-party `linux-live-wallpaper` renderer starts in background mode with **https://globe.airplanes.live/** as its default live aircraft map. Click-through mode leaves KDE windows, panels and other controls usable. For direct map interaction, the operator can use a normal browser session.
5. An original locally bundled `offline.html` standby page displays on connectivity failure. The wrapper retries the remote source every 180 seconds; it does not present invented or stale aircraft positions as live data.
6. No GPS location, hidden website credentials, custom scraping, map mirroring, self-signed TLS exceptions or remote-control permissions are configured.

## Preloaded and configured tool domains

| Purpose | Official signed Arch packages | Startup |
| --- | --- | --- |
| Desktop | `plasma-desktop`, `plasma-workspace`, `sddm`, `konsole`, `dolphin`, `kate`, `plasma-nm` | Plasma login; live wallpaper via XDG |
| Renderer | `gtk4`, `gtk4-layer-shell`, `webkitgtk-6.0` | Wallpaper launches after Wayland compositor |
| Radio | `rtl-sdr`, `soapysdr`, `soapyrtlsdr`, `rtl_433`, `gqrx` | **Manual** receiver selection and tuning |
| ADS-B | `dump1090_rs` | **Manual**, never auto-start receiver or transmit |
| GNSS | `gpsd`, `gpsd-clients` | Manual device configuration; modem probes disabled |
| Networking/security | `wireguard-tools`, `nmap`, `tcpdump`, `openssh`, `jq`, `git` | No configured keys, scans, captures, tunnels or SSH listener |
| Diagnostics | `usbutils`, `pciutils`, `python`, `python-pyserial`, `htop`, `tmux` | On demand |

Package manifests live under `profiles/mac-intel-operator/`. GNU Radio dependencies increase ISO size, so **Operator is not the lightweight rescue edition**.

## Source provenance

The user's own [linux_live_wallpaper](https://github.com/pskeffington/linux_live_wallpaper) program has an MIT license, a committed `Cargo.lock`, a `--background` CLI flag, and a GTK4/WebKitGTK6 layer-shell backend. Its source is pinned to immutable commit `ee51045dc394f73d8151906fe9f397dd3cc94060`. The build script fetches only that revision and builds `cargo build --release --locked` **as a non-root process** in an ephemeral GitHub runner. The compiled binary and exact source/lockfile hashes are recorded and staged separately into the Operator image.

The third-party [Airplanes.live Globe](https://globe.airplanes.live/) URL is linked and shown directly in WebKit. Its live content, branding, services and terms remain controlled by the website operator. Nemesis does **not** redistribute map tiles or live aircraft data; the offline design is original and contains no positions.

## Boot and network boundaries

The live-only SDDM user has no wheel/sudo credentials and no persistent profile secrets. **Do not replicate autologin** into a later installed laptop without new authentication and encryption controls. Operator starts `NetworkManager` to work with Plasma's network applet and removes **only its own staging copy** of inherited Air iwd/systemd-networkd enablement links. It retains the Air profile's masked ModemManager and disabled sshd auto-start. The original Air and rescue ISO configurations are unchanged.

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
