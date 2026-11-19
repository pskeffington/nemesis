# Nemesis Codex kickoff — current repository-only phase

**Current operating mode: `REPO_FOUNDATION`. Do not execute Linux-machine or Mac-side commands.**

The objective is to prepare all distro architecture, package manifests, Mac hardware support specifications, release design, agents and acceptance gates in `pskeffington/nemesis` before a later explicit execution handoff.

## Read first

1. [Repository-phase task prompt](codex/REPOSITORY_PHASE_PROMPT.md) — **use this now**.
2. [Repository work plan](docs/FOUNDATION_PRIORITY_PLAN.md) and [ROADMAP.md](ROADMAP.md).
3. [Architecture](docs/ARCHITECTURE.md), [edition contract](docs/EDITION_CONTRACT.md), [machine-readable edition spec](spec/editions.json).
4. [Literature](docs/research/LITERATURE_MATRIX.md), [upstream distro recon](docs/research/UPSTREAM_DISTRO_RECON.md), [decision register](docs/DECISIONS.md).
5. [AGENTS.md](AGENTS.md), [agent roster](agents/README.md), and [pass queue](codex/PASS_QUEUE.md).

## Active task

Execute **F02 — package composition specification**, entirely within GitHub. Create precise package-layer dependencies, conflict rules, official signed-source policy, design notes and CI validators. Do not run `pacman`, `mkarchiso`, QEMU or hardware commands. Preserve the existing `mac-intel` source and brand PR #5.

Use source-only CI, report exact commits and observed tests, and update status without inventing machine results. F03 hardware design and F04 release policy follow.

## Future execution — NOT YET AUTHORIZED

[Codex handoff contract](codex/HANDOFF_CONTRACT.md) contains the future go/no-go checklist. [Linux execution prompt](codex/LINUX_EXECUTION_PROMPT.md), [build runbook](codex/BUILD_RUNBOOK.md), and [hardware runbook](codex/HARDWARE_RUNBOOK.md) are **inactive** until the repository foundation is accepted and the user explicitly requests Linux-side work.

Do not promote a source-only success into a claim that an ISO builds, boots or works on any Mac.
