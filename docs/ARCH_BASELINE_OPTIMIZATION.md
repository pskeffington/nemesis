# F03-B01 — ArchISO baseline and optimization audit

Date: 2026-11-19  
State: REPO REVIEW — proposals only; no ISO behavior changes  
Scope: non-T2 Intel Mac rescue and optional MacBook Air field profile  
Authority: docs/FOUNDATION_PRIORITY_PLAN.md, docs/EDITION_CONTRACT.md, docs/FIELD_LAPTOP_ARCHITECTURE.md

## Executive decision

Retain the official ArchISO `releng` recovery image as the verified assembly baseline. Do not equate the ~1.3 GB rescue ISO with a minimal installed Arch system. Optimize an eventual *installed* field system independently, and benchmark any smaller live image against recovery, networking, boot and Mac input requirements.

## Baseline distinction

- Minimal installed Arch: a `base` package group of fundamental userspace, with kernel, firmware, bootloader, networking and desktop selected explicitly; no KDE by default.
- Official `archiso` `baseline`: minimal *live media* profile, not the same thing as an installed base system.
- Official `archiso` `releng`: broad installation/recovery medium. Nemesis stages its installed releng profile, then appends exact package deltas. Upstream contents vary with the archiso version.
- `mac-intel`: releng plus `profiles/mac-intel/packages.x86_64` and a read-only hardware report.
- `macbook-air-field`: that assembled Intel profile plus four optional packages and a read-only field report, with SSH enablement removed and ModemManager masked only in disposable staging.

## Overlap and risk register

| ID | Observation | Impact | Decision / next evidence |
| --- | --- | --- | --- |
| B01 | Official releng package list already includes intel-ucode, linux-firmware, iwd, usbutils, dmidecode, efibootmgr, smartmontools, nvme-cli, ethtool and alsa-utils in the reviewed upstream snapshot. | Much of the Intel delta is deduplicated rather than adding distinct software; package manifest size cannot be treated as image-size savings. | Keep exact-name dedup; collect actual upstream/intersection/package version evidence during Docker build. |
| B02 | Official releng includes `broadcom-wl` in the reviewed upstream snapshot. | Comments saying Nemesis does not *add* broadcom-wl remain true, but they do NOT establish that a compiled Air ISO excludes it. | Record inherited module/package inventory and licensing; no automatic activation claims; decide explicitly whether an independent lean profile should exclude it. |
| B03 | `networkmanager` is appended while releng uses iwd/systemd-networkd service wiring. | Package presence does not imply enabled service; enabling a second stack without review could break connectivity. | Inspect live/staged unit links and record exact backend before choosing one manager. |
| B04 | `bluez`, `bluez-utils`, `powertop` and `wireguard-tools` are Air option additions. | Their incremental on-image and idle-system cost is not established by source tests. | Record resolved additions, package sizes, daemon/service state in build evidence; no automatic enablement. |
| B05 | The existing ISO pass checks assembly, checksum, EFI metadata and Air SquashFS payload, not RAM, battery life, successful UEFI boot or functional internal Wi-Fi. | A successful CI image assembly is not a performance or Mac hardware qualification. | Keep separate static, build, VM and physical gates; do not publish model PASS before measurement. |
| B06 | ISO identity includes month-based labels and upstream rolling packages. | Repeat builds may not be byte-for-byte reproducible without pinning package and tool versions. | Capture upstream profile checksum, resolved package name/version list, container digest, artifact SHA256, build timestamp and signing provenance. |

## Recommended edition optimization strategy

### Tier A — verified recovery baseline (P0)
Preserve ArchISO releng disk repair, filesystem, encryption, firmware and offline shell functions. Keep installer and boot fallback unmodified. Prioritize correctness, external-media recovery, network fallback and package provenance over ISO size.

### Tier B — MacBook Air field live image (P1)
Maintain isolated Air build. Do not auto-enable SSH, ModemManager, competing Wi-Fi stacks, power managers, custom fan control, USB autosuspend or SDR capture. Benchmark distinct Air live profile against releng only after the baseline is built and boot-tested.

### Tier C — lightweight installed field workstation (P1 design only)
Propose a separate manifest instead of subtracting packages destructively from rescue:
- base system: `base`, `linux`, `linux-firmware`, Intel microcode, `sudo`, signed package/update tooling and audited bootloader choice.
- recovery: `cryptsetup`, `btrfs-progs`, `efibootmgr`, `smartmontools` as needed for selected disk layout.
- network: choose exactly one validated network management architecture; retain an offline USB network fallback.
- desktop: defer lean KDE/Wayland vs X11 decision pending graphics, accessible text scaling and idle-resource measurements.
- field operator: RF, GIS, development toolchains and optional VPN clients belong in independently installable layers, not the core base.
- no automatic internal-disk install or configuration; this is a packaging design, not deployable installation instructions.

## Quantitative benchmark protocol (not yet executed)

On an identical ArchISO snapshot and build container, capture:
1. Releng package set, Nemesis exact additions, versions and size using pacman metadata.
2. ISO bytes, compressed root filesystem bytes, archive hash, image unpacked bytes and boot mode metadata.
3. Boot in an isolated UEFI VM only after separately authorized VM execution; record success/failure, elapsed boot and memory.
4. On authorized MacBook Air models, record real idle memory after 5 minutes, CPU activity, battery power draw, thermals, ten suspend/resume cycles and a 30-minute SDR USB stability session.
5. Compare baseline and candidate in the same hardware/ambient/battery-health conditions. A candidate may advance only when functionality is non-regressed and measured savings outweigh complexity.

Do not invent size, memory, boot time, battery-hour or performance gains from source inspection.

## Ordered implementation passes

| Pass | Status | Deliverable | Gate |
| --- | --- | --- | --- |
| F03-B01 | REVIEW | This upstream comparison and optimization decision register | Reviewer checks authoritative releng snapshot and existing Nemesis staging behavior |
| F03-B02 | READY | Add reproducible CI report of upstream-vs-delta package intersection, effective versions and network/SSH/ModemManager unit state without changing the image | Reports derived from actual installed ArchISO, published as CI artifacts |
| F03-B03 | READY after B02 | Compare build artifacts and payload sizes for Intel and Air using identical pinned inputs | Hashes and sizes present, no claims about bootability |
| F03-B04 | BLOCKED | UEFI VM benchmark | Explicit authorization plus trustworthy VM runner and serial boot evidence |
| F03-B05 | BLOCKED | Model-by-model MacBook Air hardware performance evidence | Explicit physical deployment authorization, backup/recovery and recorded results |
| F04-B01 | READY | Supply chain pinning and artifact provenance plan | Defined package lock / signatures / known-good rollback pathway |

## Upstream references (retrieved 2026-11-19)

- https://wiki.archlinux.org/title/archiso
- https://github.com/archlinux/archiso/blob/master/configs/releng/packages.x86_64
- https://github.com/archlinux/archiso/blob/master/README.rst
- https://github.com/archlinux/archiso/blob/master/docs/README.profile.rst
- https://man.archlinux.org/man/mkarchiso.1.en

## Handoff guard

This file is a source-level design review. No new ISO build, installed-system packaging, boot test, user-device access, partition modification, wireless driver activation or release authorization is implied.
