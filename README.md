# Nemesis

**Nemesis** is a **Mac-first Arch-based GNU/Linux distribution under development**. Its first image targets **64-bit Intel Macs without Apple T2**, especially older hardware that benefits from a lean, repairable Linux environment. Planned T2 and Apple Silicon editions are *independent technical lanes*.

**Current state:** documented engineering scaffold. No Nemesis ISO build or physical Mac boot has been accepted.

## Development lanes
| Lane | Boot/platform | Stage |
| --- | --- | --- |
| `mac-intel` | x86_64 / 64-bit EFI Mac without T2 | first live ISO profile and diagnostics |
| `mac-t2` | x86_64 / Apple T2 with special kernel/firmware needs | separate research and trust review |
| `mac-asahi` | ARM64 / Asahi boot and device stack | future ARM architecture; **not** an x86_64 ISO |

We optimize EFI, Wi-Fi, GPU/display, trackpad/keyboard, audio, sensors, thermals, power and recoverability before custom themes or optional toolkits.

## Build on x86_64 Arch/Garuda
```bash
sudo pacman -Syu --needed git archiso shellcheck
git clone https://github.com/pskeffington/nemesis.git
cd nemesis
bash scripts/validate.sh
sudo bash scripts/build-iso.sh mac-intel
```

Generated files go to ignored `.build/` and `out/`. Build scripts do **not** repartition a Mac, write its internal storage or alter macOS security settings. A generated ISO needs later UEFI and physical Mac checks.

## Project navigation
- **Plan:** [ROADMAP.md](ROADMAP.md); [architecture](docs/ARCHITECTURE.md); [decision log](docs/DECISIONS.md).
- **Research:** [Mac/Linux literature matrix](docs/research/LITERATURE_MATRIX.md), [method](docs/research/METHODOLOGY.md), [open questions](docs/research/OPEN_QUESTIONS.md), [model candidates](docs/research/INTEL_MAC_CANDIDATES.md).
- **Codex:** [kickoff](CODEX_KICKOFF.md), [session prompt](codex/SESSION_PROMPT.md), [pass queue](codex/PASS_QUEUE.md), [build runbook](codex/BUILD_RUNBOOK.md), [hardware runbook](codex/HARDWARE_RUNBOOK.md), [research runbook](codex/RESEARCH_RUNBOOK.md).
- **Agents:** [role catalog and handoff](agents/README.md); mandatory [AGENTS.md](AGENTS.md).
- **Verification:** [build and QA](docs/BUILD_AND_QA.md), [Mac compatibility matrix](docs/MAC_COMPATIBILITY.md).
- **Source:** `profiles/mac-intel`, `scripts/prepare-profile.sh`, `scripts/build-iso.sh` and `scripts/validate.sh`.

## Operating policies
Official Arch packaging by default; upstream releng is copied to staging, never modified in place. Third-party packages, firmware rights and drivers require review. Mac hardware compatibility is established **model by model**, not from marketing years, virtual machines or successful builds. Raw ISO images, captures, machine identifiers and secrets are not committed.

Separate [linux_config](https://github.com/pskeffington/linux_config) handles host-specific research and deployment; Nemesis owns the distribution and only approved manifests cross between repos.

This is an independent project, not an official Arch Linux or Apple distribution. Existing repository license is GPL-3.0; third-party licenses remain their own.

## Branding preview (separate from ISO acceptance)

The user-space Garuda Dr460nized / KDE Plasma 6 theme development and reversible testing runbook live under [brand/](brand/README.md) and [brand/DRAGONIZED_TESTING.md](brand/DRAGONIZED_TESTING.md). This is not evidence of a Nemesis ISO or physical Mac boot.
