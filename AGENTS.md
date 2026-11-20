# Nemesis Codex and contributor operating contract

## Phase authority — current mode is repository-only

**MODE: `REPO_FOUNDATION`.** The repository, its GitHub connector and GitHub-hosted source CI are the active workspace. The developer does **not** yet work on Garuda, Arch, a physical Mac, or any connected machine.

Read in order: `README.md`, `docs/FOUNDATION_PRIORITY_PLAN.md`, `ROADMAP.md`, `spec/editions.json`, `docs/EDITION_CONTRACT.md`, `docs/ARCHITECTURE.md`, `codex/PASS_QUEUE.md` and `codex/REPOSITORY_PHASE_PROMPT.md`. This active phase supersedes any older build-next instructions or open ISO issue until an explicit handoff GO.

**Now:** architecture, hardware/research matrices, package contract, source validators, decisions, agent instructions, release specifications and handoff packet. **Narrow user-authorized exception:** a real ISO build may run inside an ephemeral GitHub-hosted **privileged Docker container**, solely as [F02-V01 CI validation](docs/DOCKER_ISO_VALIDATION.md). **Not authorized:** access to a user's Linux/Garuda/Mac hardware, local sudo/pacman/mkarchiso, QEMU, USB, firmware, partitions or physical tests. A Docker ISO build is not Mac boot evidence.

## Roles and work partition

- [Agent roster](agents/README.md); [source research](docs/research/LITERATURE_MATRIX.md) and [distro source recon](docs/research/UPSTREAM_DISTRO_RECON.md).
- Air field priority: [MacBook Air engineering agent](agents/macbook-air-field-engineer.md), [architecture](docs/FIELD_LAPTOP_ARCHITECTURE.md) and [F03-A Codex queue](codex/MACBOOK_AIR_FIELD_PASS.md). Prioritize Air7,2/6,x, offline USB network fallback, battery/thermal and radio USB stability; no default Broadcom driver, power manager or fan override.
- One accountable implementation agent per pass. Design, security and evidence reviewers may inspect independently.
- F02 package contract passed 11 GitHub source tests ([run 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336)). **F03 Mac model/device/firmware evidence schema is the next critical path**, then F04 release/provenance and F05 handoff with explicit approval.
- The independent [brand PR #5](https://github.com/pskeffington/nemesis/pull/5) is optional P2. Do not overwrite, merge or bake it into `mac-intel` to accelerate boot work.
- `linux_config` is a separate host configuration project. Do not import machine-specific secrets/config into this distro without a dependency review.

## OPERATOR — live aircraft globe desktop

Current Operator objective: preloaded Plasma Wayland and field tools with the user's pinned MIT `linux_live_wallpaper` displaying `https://globe.airplanes.live/` at login. See [design and source contract](docs/OPERATOR_EDITION.md), [OP-01/OP-02 pass queue](codex/OPERATOR_PASS.md), and [desktop agent](agents/operator-desktop-engineer.md). Build Rust source from pinned commit **without root**; stage binary in a separate trusted Docker `mkarchiso` run. Test auto-start/Wayland runtime separately; do not treat a source or payload check as booted. Keep the generic Intel rescue and Air editions unchanged, no default SSH, radio capture, external geolocation, secrets or physical device operations.

## Platform contract

1. `mac-intel` — Intel x86_64 without T2, candidate live/rescue profile scaffold, **not built or booted**.
2. `mac-intel-desktop` remains planned. `mac-intel-operator` is a distinct **source-scaffold** with KDE, Airplanes.live live wallpaper and preloaded tools, independently CI-built; never default enabled in rescue/lean Air image.
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
5. If a gate fails, repair that gate; do not run local machines or silently skip to M02. F02-V01 container validation is explicitly scoped to GitHub-hosted Docker only; it does not grant a general execution GO.
6. Before any future physical execution, complete `codex/HANDOFF_CONTRACT.md` and receive explicit human GO.

**Default next pass:** F03 Mac hardware/firmware evidence specification. **Execution status: NO-GO.**

## Operator lean package governance

The Operator’s default is a small *usable* base, not a full GNU Radio/GIS workstation. Read [OP-P01 literature matrix](docs/research/OPERATOR_PACKAGE_LIT_MATRIX.md) and [toolkit contract](spec/operator-kits.json) before editing packages. Preserve KDE/Wayland, Firefox for interactive globe, pinned WebKitGTK wallpaper and minimal RF/hardware diagnostics. Heavy and specialized packages live in distinct optional signed-Arch manifests; the live medium offers only read-only `nemesis-kit list/show`, no installer or unauthorized root. An explicit [Operator-only releng exclusions file](profiles/mac-intel-operator/releng-drop.packages.x86_64) handles upstream inherited packages; do not remove signed boot/USB recovery/installer requirements or touch the rescue/Air profiles. Image size and hardware battery performance require measured evidence, never line-count estimates.
