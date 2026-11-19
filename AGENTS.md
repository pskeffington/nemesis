# Nemesis Codex and contributor operating contract

## Phase authority — current mode is repository-only

**MODE: `REPO_FOUNDATION`.** The repository, its GitHub connector and GitHub-hosted source CI are the active workspace. The developer does **not** yet work on Garuda, Arch, a physical Mac, or any connected machine.

Read in order: `README.md`, `docs/FOUNDATION_PRIORITY_PLAN.md`, `ROADMAP.md`, `spec/editions.json`, `docs/EDITION_CONTRACT.md`, `docs/ARCHITECTURE.md`, `codex/PASS_QUEUE.md` and `codex/REPOSITORY_PHASE_PROMPT.md`. This active phase supersedes any older build-next instructions or open ISO issue until an explicit handoff GO.

**Now:** architecture, hardware/research matrices, package contract, source validators, decisions, agent instructions, security/release specifications and handoff packet. **Not now:** Linux deployment, `sudo`, package installation, `mkarchiso`, QEMU, USB writing, host changes or Mac tests. GitHub Actions source/profile compatibility CI is allowed; it is not an ISO build.

## Roles and work partition

- [Agent roster](agents/README.md); [source research](docs/research/LITERATURE_MATRIX.md) and [distro source recon](docs/research/UPSTREAM_DISTRO_RECON.md).
- One accountable implementation agent per pass. Design, security and evidence reviewers may inspect independently.
- F02 package architecture is the next critical path. F03 Mac support policy and F04 release/provenance follow. F05 handoff needs P0 acceptance and explicit user approval.
- The independent [brand PR #5](https://github.com/pskeffington/nemesis/pull/5) is optional P2. Do not overwrite, merge or bake it into `mac-intel` to accelerate boot work.
- `linux_config` is a separate host configuration project. Do not import machine-specific secrets/config into this distro without a dependency review.

## Platform contract

1. `mac-intel` — Intel x86_64 without T2, candidate live/rescue profile scaffold, **not built or booted**.
2. `mac-intel-desktop` / `mac-intel-operator` — planned optional layers; never default-enabled in core.
3. `mac-t2` — separate T2 kernel and firmware research, no stock-image equivalence.
4. `mac-asahi` — distinct ARM64/Asahi boot and installer lane, never an x86_64 ISO derivative.

Use `spec/editions.json` as a declarative planning record; it is not a working package resolver.

## Safety and source authority

- No unattended partition/firmware writes, firmware extraction, insecure package signatures, default SSH credentials, secret/serial/network-identifying log commits, or unauthorized Apple firmware redistribution.
- Default to official signed Arch packages. External/AUR/T2 sources require provenance, license and security decision before any integration.
- Preserve GPL-3.0 and check third-party licenses independently. Upstream distros are research references, not permission to copy code.
- Source test != ISO build != VM boot != Apple physical test != release acceptance.
- Keep human-facing, grep-searchable comments and meaningful separators. Preserve current user/PR changes and never force-push.
- Repository source has no pricing or commercial valuation data.

## Pass protocol

1. Inspect actual branch/head, previous approved pass and conflicting open issues/PRs.
2. Choose one P0/F pass; state owner, inputs/dependencies, exact paths, acceptance, rollback and evidence.
3. Make minimal reversible source/docs changes. Add deterministic tests and run/inspect GitHub CI.
4. Record pass status only from observed results; commit source change, CI link, open defects and next repo-only pass.
5. If a gate fails, repair that gate; do not run local machines or silently skip to M02.
6. Before any future physical execution, complete `codex/HANDOFF_CONTRACT.md` and receive explicit human GO.

**Default next pass:** F02 package composition specification. **Execution status: NO-GO.**
