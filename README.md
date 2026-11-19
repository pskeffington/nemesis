# Nemesis

**Nemesis** is an independent, Mac-first Arch-based Linux distribution under development. The first eventual execution target is **64-bit EFI Intel Macs without T2**; Intel T2 and Apple Silicon have separate hardware/boot research lanes.

## Current status — repository foundation, not Linux deployment

**Active work is entirely in this GitHub repository.** We are specifying the distro's architecture, package layers, hardware/firmware policy, automated source checks, upstream provenance, release boundaries and Codex handoff. We are **not** currently deploying to Garuda, building an ISO, booting QEMU or testing Macs.

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
- **Existing source:** [profiles/mac-intel](profiles/mac-intel), [prepare-profile.sh](scripts/prepare-profile.sh), [build-iso.sh](scripts/build-iso.sh), [source tests](tests).

## Prior accepted evidence

- Official ArchISO releng staging via CI on signed ArchISO 92-1: [run 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858).
- Edition contract source CI: [run 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155).
- Package/edition contract: [11 source tests passed, run 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336); no runtime package resolution.
- Comparable distribution source research: [UPSTREAM_DISTRO_RECON.md](docs/research/UPSTREAM_DISTRO_RECON.md).
- KDE/Dragonized-inspired visual identity remains a **separate, reversible user-space preview** in [PR #5](https://github.com/pskeffington/nemesis/pull/5), not a core boot dependency.

## Future execution: intentionally not active

When the repository foundation is accepted and an explicit handoff GO is given, the Linux implementation operator will follow [`codex/LINUX_EXECUTION_PROMPT.md`](codex/LINUX_EXECUTION_PROMPT.md) and the existing [build runbook](codex/BUILD_RUNBOOK.md). These files are retained for later execution; **do not treat them as today's instructions**.

Official signed Arch packages by default. No automatic internal Mac disk changes, proprietary firmware redistribution, default remote credentials, or unreviewed package signature bypass. Hardware is verified model-by-model; a successful source check or ISO build is never proof of Mac compatibility.

Nemesis is not an official Arch Linux or Apple distribution. The repository retains GPL-3.0; dependencies and firmware have independent license obligations. Host-specific work remains in [linux_config](https://github.com/pskeffington/linux_config) and is not copied into Nemesis images without review.
