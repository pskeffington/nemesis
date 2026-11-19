# Nemesis

**Nemesis** is a Mac-first, Arch-based GNU/Linux distribution under active development. The initial release target is a live/install ISO for **64-bit Intel Macs without an Apple T2 chip**, particularly hardware that benefits from a lean, repairable Linux system.

**Status:** foundation source only. No Nemesis ISO has been built, boot-tested, or released yet.

## Hardware development lanes

| Lane | Target | Current state |
| --- | --- | --- |
| `mac-intel` | x86_64 Intel Macs without T2 | First build profile; physical support not yet verified |
| `mac-t2` | Intel Macs with Apple T2 | Research / separate kernel, firmware and input-device gates |
| `mac-asahi` | Apple Silicon ARM64 | Future independent boot/platform workstream; not an archiso x86_64 variant |

The objective is a maintainable distribution, not a blanket assertion that every Mac works. Hardware compatibility will be proved model by model.

## First build on Arch Linux or Garuda Linux (x86_64)

```bash
sudo pacman -Syu --needed git archiso shellcheck
git clone https://github.com/pskeffington/nemesis.git
cd nemesis
bash scripts/validate.sh
sudo bash scripts/build-iso.sh mac-intel
```

The builder copies the installed Arch `releng` profile, applies only the Nemesis overlay and package additions, then calls `mkarchiso`. It does **not** repartition a Mac, install to internal storage, or modify macOS.

Generated ISO(s), SHA-256 files, work trees and staging profiles live in ignored `out/` and `.build/` directories. The builder refuses to reuse existing work/stage directories; inspect and remove those directories manually before another attempt.

The output is an **initial live environment**, not a polished desktop release or proven installer. See [build and QA](docs/BUILD_AND_QA.md) for acceptance gates.

## Repository

- [Architecture and hardware strategy](docs/ARCHITECTURE.md)
- [Mac hardware matrix](docs/MAC_COMPATIBILITY.md)
- [Build and validation](docs/BUILD_AND_QA.md)
- [Roadmap and acceptance status](ROADMAP.md)
- [Technical decisions](docs/DECISIONS.md)
- [Contributor and agent instructions](AGENTS.md)

**Related work:** [linux_config](https://github.com/pskeffington/linux_config) contains machine-level Linux configuration and system research. Nemesis owns its distribution image, build pipeline, hardware policies and releases. Do not copy host-specific secrets or unreviewed machine configs into a public ISO.

## Principles

1. Mac hardware first: EFI, Wi-Fi, GPU, trackpad, audio, sensors, thermals, power, suspend and recoverability.
2. Preserve a safe boot and recovery path; no unattended internal-disk writes.
3. Use official Arch packaging and a traceable upstream build. Vendor patches only by explicit, reviewed decision.
4. Treat T2 and Apple Silicon as different boot/support platforms, not optional package flags.
5. Record actual build, VM, physical boot and hardware verification separately; never infer acceptance from source changes alone.

This is an independent project, not an official Arch Linux or Apple distribution. The repository carries the existing GPL-3.0 license; third-party packages and firmware retain their own licenses.
