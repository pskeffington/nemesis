# M3 optimization — isolated ARM64 KDE VM before native hardware

**Pass M3-V01 | Status: review candidate, source/CI only.** This source branch is stacked on [theme PR #24](https://github.com/pskeffington/nemesis/pull/24). It does not touch macOS or change the x86_64 Intel rescue/Air/Operator images.

## Two targets, with different claims

| Target | Environment | Purpose | Evidence |
| --- | --- | --- | --- |
| M3-V01 | Standard Fedora KDE 45 **aarch64** in an UTM-virtualized Linux VM on macOS M3 | KDE theme, interactive object decoding, responsiveness, memory and safe rollback | CI/readiness only; M3 VM not run |
| M3-N01 (later) | Fedora Asahi Remix 45 on an actual supported M3-family Mac | Native Apple boot, GPU, energy, sleep and device support | Research only; not installed |

The Intel Nemesis ArchISO is x86_64. Running it under QEMU emulation is not representative of M3 CPU performance. A generic ARM64 VM uses virtual hardware, **not** the native Asahi Apple device tree/boot chain. As of 2026-11-21, Fedora Asahi Remix 45 supports initial M3/M3 Pro/M3 Max systems, but the released M3 graphics driver does **not** provide performant hardware-accelerated 3D. Do not infer native GPU compatibility from VM or headless tests.

Sources: [Fedora Asahi 45](https://fedoramagazine.org/fedora-asahi-remix-45-is-now-available/), [Asahi M3 matrix](https://asahilinux.org/docs/platform/feature-support/m3/), [Asahi November progress](https://asahilinux.org/2026/11/progress-report-7-3/), [Fedora KDE downloads](https://fedoraproject.org/kde/download/), [UTM](https://getutm.app/).

## UTM guest starting presets (not measured performance claims)

| macOS host RAM | Guest CPU | Guest RAM | VM disk |
| --- | --- | --- | --- |
| 8 GiB | 2 vCPU | 4 GiB | 32 GiB |
| 16 GiB | 4 vCPU | 6 GiB | 48 GiB |
| 24 GiB or more | 4 vCPU | 8 GiB | 64 GiB |

These values are proposals in [spec/m3-arm64-vm.json](../spec/m3-arm64-vm.json), not minimum vendor requirements. Always leave memory for macOS. In UTM select **Virtualize → Linux** and the official Fedora KDE Plasma Desktop 45 **aarch64** Live ISO, verify Fedora-published signed checksums, use UTM default virtual graphics and begin at 1920×1200. Use a disposable virtual disk and snapshot. No shared host folders, USB SDR passthrough, host firmware or physical partitions. Guest installation is a separate user-controlled action and writes only to the VM disk.

## Optimization method

1. **Confirm architecture and resources** in the guest, with no root:
   ~~~sh
   python3 scripts/m3-vm-audit.py --require-arm64
   ~~~
   The output is read-only aggregate guest CPU/memory, KDE binary presence and coarse virtual display category. It deliberately omits usernames, hostnames, serials, MAC addresses and network details. It does not attest that the guest ran on an actual M3.
2. **Record untreated baseline:** three supervised cold-boot-to-login observations; idle memory five minutes after login; CPU usage; 100% and 200% display scaling; and whether the virtual graphics driver is usable. No measurements have yet been supplied. Do **not** disable zram, swap, power management, security features or services preemptively.
3. **Stage the Nemesis appearance as the Linux guest user**, never sudo:
   ~~~sh
   bash brand/scripts/dragonized.sh doctor
   bash brand/scripts/dragonized.sh plan
   bash brand/scripts/dragonized.sh install
   bash brand/scripts/dragonized.sh status
   ~~~
   The reviewed per-user installer hash-tracks managed files and blocks collisions. If the existing KDE scheme is named and recoverable, use **apply** and optionally **apply-style**; otherwise record the original settings and select Nemesis manually in KDE System Settings. The Inspector must be added manually via Plasma Add Widgets.
4. **Compare UI before/after:** all eight icons render, selected and hover states work, focus is visible via keyboard, contrast is adequate, Konsole is legible and 100%/200% scaling does not truncate labels. Prefer upstream KDE graphics defaults and measure rendering before choosing a software fallback. No unmeasured optimization flags are activated.
5. **Only after a stock baseline**, optionally display https://globe.airplanes.live/ in a browser; record memory/CPU delta and note remote/offline behavior. The existing Intel Operator Rust wallpaper executable is not an ARM64 binary and is not automatically copied into the guest. A pinned ARM64 rebuild and Qt/Wayland layering review would be separate work. Never auto-start SDR capture or receivers.
6. **Recover** by removing the Inspector from any active panel and running the existing guest-user restore commands:
   ~~~sh
   bash brand/scripts/dragonized.sh restore-style
   bash brand/scripts/dragonized.sh restore
   bash brand/scripts/dragonized.sh uninstall
   ~~~
   Do not delete manually modified files or override independent user theme changes.

The purpose is to make repeatable measurements and reversible theme testing possible, not to invent M3 FPS, battery, memory savings or GPU benchmark numbers.

## Native M3 backlog (explicit GO required)

Research the exact M3 model, Asahi kernel/m1n1, display/DCP, Mesa GPU readiness, Wi-Fi, audio, sleep, battery and recovery separately. Fedora Asahi on real hardware requires a reviewed backup and partition/boot plan; do not copy generic ARM64 virtual-machine firmware or Intel ArchISO boot files to a native M3 target. Any future Arch Linux ARM-based distro requires an independently reviewed trusted package/boot chain. No physical Apple Silicon device is accepted by this source change.

## CI, dependencies and rollback

[m3-arm64.yml](../.github/workflows/m3-arm64.yml) checks deterministic source contracts and a **native ARM64 Linux GitHub runner**. That runner is **not** an M3 Mac and does **not** boot UTM. The existing repo-only handoff policy and source/build/GUI/hardware acceptance levels remain separate. Stacked PR dependency: first resolve [#24](https://github.com/pskeffington/nemesis/pull/24); then review/rebase this pass. To roll back, discard the unmerged branch and/or restore the user-managed preview inside the disposable VM. Intel source profiles remain unaffected.
