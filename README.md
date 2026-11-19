# Nemesis

**Nemesis** is an independent, Mac-first Arch-based Linux distribution under development. The first eventual execution target is **64-bit EFI Intel Macs without T2**; Intel T2 and Apple Silicon have separate hardware/boot research lanes.

## Current status — repository foundation, not Linux deployment

**Active work remains in this GitHub repository and its hosted CI.** We are specifying architecture, package layers, hardware/firmware policies, provenance and handoff. **A narrowly authorized Docker CI run now attempts an Intel ISO build on an ephemeral GitHub runner**, not on any user's Garuda/Mac. This does not authorize QEMU, USB, firmware, partitions, or real hardware testing.

The earlier scaffold passed Bash/ShellCheck/fixtures and actual packaged ArchISO 92-1 profile-staging checks in GitHub Actions. The repository-only edition and package contracts also passed 11 GitHub CI tests. **No Nemesis ISO or physical Mac boot has been demonstrated.**

**Current authority:** [foundation priorities](docs/FOUNDATION_PRIORITY_PLAN.md) → [edition/platform contract](docs/EDITION_CONTRACT.md) → [roadmap](ROADMAP.md) → [Codex repository-phase prompt](codex/REPOSITORY_PHASE_PROMPT.md). The [future Linux handoff contract](codex/HANDOFF_CONTRACT.md) is **NO-GO** until reviewed and explicitly authorized.

## Engineering structure

| Platform / edition | Target | Source readiness | Execution |
| --- | --- | --- | --- |
| `mac-intel` | non-T2 Intel x86_64 rescue/live ISO | ArchISO overlay committed, source CI accepted | **Deferred** |
| `mac-intel-desktop` | optional accessible KDE desktop | design-only | Deferred |
| `mac-intel-operator` | optional field / RF / engineering edition | design-only | Deferred |
| `mac-t2` | Intel Macs with T2-specific kernel and device stack | research-only | Deferred |
| `mac-asahi` | Apple Silicon ARM64/Asahi platform | research-only | Deferred |

Machine-readable scope lives in [`spec/editions.json`](spec/editions.json); source-only tests prevent premature hardware/release claims. This specification is **not automatically consumed by the builder**.

## Repository navigation

- **Current planning:** [foundation priority plan](docs/FOUNDATION_PRIORITY_PLAN.md), [ROADMAP.md](ROADMAP.md), [Codex pass queue](codex/PASS_QUEUE.md).
- **Architecture:** [system design](docs/ARCHITECTURE.md), [edition contract](docs/EDITION_CONTRACT.md), [package composition](docs/PACKAGE_COMPOSITION.md), [decisions](docs/DECISIONS.md), [release gates](docs/RELEASE_GATES.md).
- **Research:** [Mac hardware literature](docs/research/LITERATURE_MATRIX.md), [comparative distro source recon](docs/research/UPSTREAM_DISTRO_RECON.md), [Intel Mac candidates](docs/research/INTEL_MAC_CANDIDATES.md), [open questions](docs/research/OPEN_QUESTIONS.md).
- **Agent and Codex instructions:** [AGENTS.md](AGENTS.md), [agent catalog](agents/README.md), [repository-phase prompt](codex/REPOSITORY_PHASE_PROMPT.md), [handoff contract](codex/HANDOFF_CONTRACT.md), [CODEX_KICKOFF.md](CODEX_KICKOFF.md).
- **Docker ISO validation:** [isolated build policy](docs/DOCKER_ISO_VALIDATION.md), [GitHub workflow](.github/workflows/docker-archiso.yml), [container script](docker/archiso/validate-build.sh); current validation status in [F02-V01 issue #12](https://github.com/pskeffington/nemesis/issues/12).
- **Existing source:** [profiles/mac-intel](profiles/mac-intel), [prepare-profile.sh](scripts/prepare-profile.sh), [build-iso.sh](scripts/build-iso.sh), [source tests](tests).

## Prior accepted evidence

- Official ArchISO releng staging via CI on signed ArchISO 92-1: [run 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858).
- Edition contract source CI: [run 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155).
- Package/edition contract: [11 source tests passed, run 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336); no runtime package resolution.
- Comparable distribution source research: [UPSTREAM_DISTRO_RECON.md](docs/research/UPSTREAM_DISTRO_RECON.md).
- KDE/Dragonized-inspired visual identity remains a **separate, reversible user-space preview** in [PR #5](https://github.com/pskeffington/nemesis/pull/5), not a core boot dependency.

## Future execution: intentionally not active

When the repository foundation is accepted and an explicit handoff GO is given, the **local-machine** Linux implementation operator will follow [`codex/LINUX_EXECUTION_PROMPT.md`](codex/LINUX_EXECUTION_PROMPT.md) and the existing [build runbook](codex/BUILD_RUNBOOK.md). These files are retained for later execution; **do not treat them as today's instructions**.

Official signed Arch packages by default. No automatic internal Mac disk changes, proprietary firmware redistribution, default remote credentials, or unreviewed package signature bypass. Hardware is verified model-by-model; a successful source check or ISO build is never proof of Mac compatibility.

Nemesis is not an official Arch Linux or Apple distribution. The repository retains GPL-3.0; dependencies and firmware have independent license obligations. Host-specific work remains in [linux_config](https://github.com/pskeffington/linux_config) and is not copied into Nemesis images without review.

## Experimental theme ISO staging (GitHub CI only)

The separate, opt-in `mac-intel-theme-preview` target adds Nemesis KDE artwork and signed-repository package names without modifying the default rescue ISO. See [theme ISO integration](docs/THEME_ISO_PREVIEW.md) and [non-privileged Docker staging](.github/workflows/theme-iso-stage.yml). A real theme ISO build requires an explicit trusted-main Docker dispatch; boot and graphical login remain untested.

## Nemesis interactive theme controls (optional)

The draft [brand/](brand/) track now includes a Plasma 6 icon/object inspector with eight selectable themed objects, keyboard/mouse feedback, accent and high-focus controls, and reset. Its [Qt6 Docker test](https://github.com/pskeffington/nemesis/actions/runs/44613035058) passed; it is only included in the opt-in `mac-intel-theme-preview` staged image and not in `mac-intel` rescue. Real graphical login, Plasma/Kvantum interaction, themed ISO boot, and Mac hardware remain untested.
