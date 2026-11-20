# Nemesis Codex kickoff — current repository-only phase

**Current operating mode: `REPO_FOUNDATION`. Do not execute Linux-machine or Mac-side commands.**

The objective is to prepare all distro architecture, package manifests, Mac hardware support specifications, release design, agents and acceptance gates in `pskeffington/nemesis` before a later explicit execution handoff.

## Read first

1. [Repository-phase task prompt](codex/REPOSITORY_PHASE_PROMPT.md) — **use this now**.
2. [Repository work plan](docs/FOUNDATION_PRIORITY_PLAN.md) and [ROADMAP.md](ROADMAP.md).
3. [Architecture](docs/ARCHITECTURE.md), [edition contract](docs/EDITION_CONTRACT.md), [machine-readable edition spec](spec/editions.json).
4. [Literature](docs/research/LITERATURE_MATRIX.md), [upstream distro recon](docs/research/UPSTREAM_DISTRO_RECON.md), [decision register](docs/DECISIONS.md).
5. [AGENTS.md](AGENTS.md), [agent roster](agents/README.md), and [pass queue](codex/PASS_QUEUE.md).

## Active task — Nemesis Operator live aviation desktop

The user's selected current workstream is **OP-01/OP-02 Operator edition**: KDE Plasma Wayland with [live aircraft globe](https://globe.airplanes.live/) as default background via the pinned first-party Rust [linux_live_wallpaper](https://github.com/pskeffington/linux_live_wallpaper), with preloaded SDR/ADS-B/GNSS/network tools. Follow [Operator execution contract](codex/OPERATOR_PASS.md), [Operator specification](docs/OPERATOR_EDITION.md), and [issue #19](https://github.com/pskeffington/nemesis/issues/19). The separate Operator source is merged in [commit e36930c](https://github.com/pskeffington/nemesis/commit/e36930c79a5f80c36dc200fcc473d0a9d1be355d).

OP-01 source/native ArchISO tests passed [CI 44734587794](https://github.com/pskeffington/nemesis/actions/runs/44734587794) and [foundation 44734587975](https://github.com/pskeffington/nemesis/actions/runs/44734587975). OP-02 [Docker 44734587874](https://github.com/pskeffington/nemesis/actions/runs/44734587874) built the signed toolchain and compiled the pinned Rust binary as non-root; independent ISO/payload assembly remains in progress at this revision. Inspect actual job completion before accepting the ISO.

**Current execution exception:** approved GitHub-hosted disposable Docker may compile the binary and ISO. **Not authorized:** local Garuda/Mac commands, USB/EFI/disk work, physical testing, and QEMU boot. Theme [PR #5](https://github.com/pskeffington/nemesis/pull/5) is parallel; the online map is the visual surface and is never bundled/cached as offline aircraft data. F03 Mac hardware, F04 release policy and F05 handoff continue as independent later gates.

## Future execution — NOT YET AUTHORIZED

[Codex handoff contract](codex/HANDOFF_CONTRACT.md) contains the future go/no-go checklist. [Linux execution prompt](codex/LINUX_EXECUTION_PROMPT.md), [build runbook](codex/BUILD_RUNBOOK.md), and [hardware runbook](codex/HARDWARE_RUNBOOK.md) are **inactive** until the repository foundation is accepted and the user explicitly requests Linux-side work.

Do not promote a source-only success into a claim that an ISO builds, boots or works on any Mac.
