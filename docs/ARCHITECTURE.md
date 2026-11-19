# Nemesis architecture — Mac-first

**Current authority: repository foundation only.** See [F00–F06 priority plan](FOUNDATION_PRIORITY_PLAN.md), [declarative edition contract](EDITION_CONTRACT.md) and [future Codex handoff](../codex/HANDOFF_CONTRACT.md). This architecture illustrates *future* build/boot flow, not an instruction to execute it now. The JSON edition model is not yet wired to the builder.

## Architecture choice

Nemesis is a distribution assembled from official Arch Linux packages using the **installed ArchISO releng profile** as a controlled upstream base. We keep only the Nemesis package delta, file overlay, reproducible preparation script and build policy in this repository.

```text
Arch/Garuda x86_64 build host
  + official archiso releng (copied; upstream untouched)
  + profiles/mac-intel/packages.x86_64
  + profiles/mac-intel/airootfs/
  + scripts/prepare-profile.sh
  -> staged archiso profile
  -> mkarchiso
  -> Nemesis Intel Mac ISO + SHA-256
  -> UEFI VM gate
  -> external-boot physical Mac gate
  -> later graphical/installed-system gate
```

### Platform 1: Intel Mac (without T2) — active
- x86_64 architecture, Apple UEFI, stock Arch kernel and early live shell.
- First iteration uses the upstream releng bootloader and Arch installer; no custom partitioner or automatic installation.
- Additional official packages provide Intel microcode, Linux firmware, networking and read-only device inventory.
- Identify Broadcom Wi-Fi by PCI ID before choosing a driver; support is model-specific.
- Graphics, audio, trackpad, camera, suspend, fan control and power profiles require real-device tests.
- Prefer working, maintainable defaults over AUR drivers or unreviewed kernel tweaks.

### Platform 2: Intel Mac with T2 — separate design lane
- T2 models may require a patched kernel and extra drivers to make internal keyboard, trackpad, audio and wireless devices work.
- T2 firmware workflows can require files obtained locally from macOS; do not commit or distribute them.
- T2 secure-boot/external-media settings are a documented, user-controlled precondition, never modified by the ISO.
- Scope an isolated T2 image only after kernel provenance, licensing, build and hardware safety review.

### Platform 3: Apple Silicon — separate ARM64 boot lane
- M-series Macs do not boot this x86_64 ISO. They require Apple Silicon platform boot and device support.
- Follow Asahi upstream support matrices; do not adapt x86_64 boot entries by renaming them.
- Before writing ARM64 packaging, document supported SoCs, kernel, bootloader, device trees, graphics, installer and firmware responsibilities.
- No ARM64 artifact is promised in phase 1.

## Distribution layers (longer term)
1. **core:** trusted Arch packages, UEFI boot, kernel, filesystem, networking, package management, recovery.
2. **mac-hardware:** model-specific drivers, firmware policy, trackpad, Wi-Fi, media, thermals, battery and suspend.
3. **desktop:** accessible KDE/Wayland experience, HiDPI scaling, installer and recovery tooling.
4. **operator modules:** optional RF/SDR, networking/security and engineering toolsets drawn from separately maintained manifests.

Release channels must keep the core install small. Hardware-specific components should be conditionally enabled based on **verified device identifiers**, not Mac marketing year alone.

## Security and packaging policy
- Never enable SSH with default credentials in a release ISO.
- Use Arch package signatures and pinned evidence for each generated build; verify third-party code before use.
- No firmware extraction, disk repartition, bootloader changes or macOS security setting mutations in build scripts.
- Do not bundle proprietary Apple firmware without rights and compliance review.
- Keep user serials, network captures and machine-local logs out of the public repository.
- Reproducibility target: record ArchISO/package versions, source commit and image checksum. Bit-for-bit reproducibility is a future gate.

## Upstream source references
- ArchISO: https://wiki.archlinux.org/title/archiso
- Arch Mac guide: https://wiki.archlinux.org/title/Mac
- Apple Intel boot chain: https://support.apple.com/guide/security/boot-process-sec5d0fab7c/web
- T2 device support: https://wiki.t2linux.org/state/
- T2 wireless notes: https://wiki.t2linux.org/guides/wifi-bluetooth/
- Asahi project/platform: https://asahilinux.org/docs/
