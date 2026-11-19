# Nemesis foundation — current repository-only work plan

**Effective 2026-11-19.** This document governs active work until an explicit Linux handoff authorization is issued. The GitHub repository is the **current work environment**; a local Arch/Garuda system is **not** the active environment. No work item in this phase authorizes root access, ISO compilation, QEMU, USB flashing, macOS/EFI changes or physical deployment.

## Goal and acceptance

Deliver a coherent, source-controlled Mac-first Arch distro specification that an implementation Codex can execute without having to invent platform boundaries, package trust, module dependencies, release standards or rollback behavior. Success in this phase means **reviewable files, declared dependencies, passing source-only CI, and a pinned handoff packet**, not a functioning distro.

Keep the first execution target **non-T2 64-bit EFI Intel Macs**. Intel T2 and Apple Silicon have independent research/design lanes. The visual identity is optional and never blocks a bootable rescue baseline.

## P0 → P2 priority table

| Rank | Pass | Accountable agent | Concrete GitHub deliverable | Gate | Status |
| --- | --- | --- | --- | --- | --- |
| P0-0 | F00 Source baseline and upstream recon | distro-architect | Archived comparative research, ArchISO baseline, source/fixture test evidence | Traceable repo/CI SHA | ACCEPTED |
| P0-1 | F01 Edition and platform contract | distro-architect | `spec/editions.json`; `docs/EDITION_CONTRACT.md`; `tests/test_foundation.py` | GitHub foundation CI green, no future-platform support claims | ACCEPTED (CI source check) |
| P0-2 | F02 Package composition specification | archiso-build-engineer | `spec/package-layers.json`, `docs/PACKAGE_COMPOSITION.md`, source tests | 11 source tests [CI 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336) | ACCEPTED (repo contract) |
| P0-3 | F03 Mac hardware support specification | intel-mac-compatibility | Per-model/PCI ID matrix, EFI/input/display/audio/network/thermals/sleep evidence contract, T2/ARM exclusions | Source-backed, no false PASS devices; no firmware redistribution | READY — ACTIVE NEXT, [#9](https://github.com/pskeffington/nemesis/issues/9) |
| P0-4 | F04 Build provenance and release policy | security-release-reviewer | Signed package/update boundaries, artifact manifest, checksums, SBOM candidate, rollback and test-level separation | Reviewable release criteria; no unsigned trust bypass | NOT STARTED |
| P1-1 | F05 Codex execution handoff | build-qa-engineer | `codex/HANDOFF_CONTRACT.md`, task pass queue, exact future commands and stop rules, pinned refs | All P0 gates accepted and human explicitly approves moving to execution | NOT STARTED — packet template now prepared |
| P2-1 | F06 Nemesis artwork and KDE preview | optional visual-development branch | Reversible brand assets and source, license review, UI accessibility checks | No forced ISO integration; PR may remain open | IN PARALLEL / NOT A BOOT BLOCKER |
| HOLD | M02 ISO compilation | archiso-build-engineer (future) | Signed-Arch based ISO and SHA-256 | F05 accepted **and** user explicitly switches phase | DEFERRED |
| HOLD | M03 virtual UEFI | uefi-boot-validator (future) | OVMF boot log | M02 observed | DEFERRED |
| HOLD | M04 physical Mac acceptance | intel-mac-compatibility (future) | Redacted model-level hardware report and recovery | M03 observed, hardware approved | DEFERRED |

## Dependency graph

```text
F00 (accepted source baseline and upstream recon)
  └─> F01 (edition/platform contract; source CI verified)
         ├─> F02 (package composition and conflict rules)
         └─> F03 (hardware coverage and driver/firmware decision matrix)
                 └─> F04 (release provenance and safety policy)
F02 + F03 + F04 ──> F05 (handoff-ready source, responsibilities, go/no-go)
F06 (theme) is separate and optional; never blocks boot or security.
F05 + explicit human GO ──> M02 (actual ISO build) ──> M03 VM ──> M04 Mac.
```

## Pass contracts

### F02 — package architecture
- **Inputs:** `spec/editions.json`, current `profiles/mac-intel/packages.x86_64`, upstream sources UP-01..05, existing ArchISO profile.
- **Steps:** define layer data structure, OS/edition selection precedence and duplicate/conflict detection; review signed repositories, external source exceptions and old Intel CPU baseline; keep optional KDE/operator packages out of the core image.
- **Outputs:** machine-readable proposed package/layer matrix, accompanying design notes and repository-side tests.
- **Acceptance:** CI verifies no impossible platform mix, unique packages, correct dependency DAG, no unsigned package feed or silent changes to implemented baseline.
- **Rollback:** revert the spec/test change; do not mutate root or boot assets.
- **Owner / status:** archiso-build-engineer / READY.

### F03 — hardware architecture
- **Inputs:** candidate Mac models, literature matrix, T2/Asahi upstream support data.
- **Steps:** define model/PCI ID discovery, diagnostic evidence fields, firmware provenance and fallback paths for graphics/Wi-Fi/audio/trackpad/thermal/suspend.
- **Outputs:** inspectable hardware contract and source-linked compatibility decisions; no untested device PASS claims.
- **Acceptance:** per-model feature status is explicit, unknown IDs remain unknown and no firmware extraction or privileged changes are silently enabled.
- **Owner / status:** intel-mac-compatibility with security reviewer / READY.

### F04 — security, update and release design
- **Inputs:** F02/F03, `docs/RELEASE_GATES.md`, published upstream trust requirements.
- **Steps:** specify package signature trust, version provenance, image/SBOM/hashes, CI supply-chain boundaries, downgrade/rollback behavior, recovery, kernel update policy and release blockers.
- **Outputs:** architecture decision, release evidence schema and security review checklist.
- **Acceptance:** no release claim without real G1/G2/G3; all external binaries have licensing/provenance decisions.
- **Owner / status:** security-release-reviewer / NOT STARTED.

### F05 — explicit handoff
- **Inputs:** accepted F02/F03/F04, green source CI, open defects, branch/commit, machine prerequisites and known hardware target.
- **Steps:** construct and verify handoff packet; rehearse text-only task sequence; define permissions and one-pass/one-gate discipline.
- **Outputs:** [Codex handoff contract](../codex/HANDOFF_CONTRACT.md), updated work queue, go/no-go decision.
- **Acceptance:** all handoff fields complete and **explicit authorization** to leave repo-only mode. A CI success alone never authorizes execution.
- **Owner / status:** build-qa-engineer / NOT STARTED.

## Decision register

- **R-F01:** premature execution: old docs or issues say “build next.” Current authoritative scope is this plan; build instructions are **future reference**, not an active task.
- **R-F02:** package drift and third-party signing: keep official Arch default, documented exceptions only.
- **R-F03:** overly broad “Mac compatible”: define model/feature status and retain T2/ARM separation.
- **R-F04:** theme vs. critical path: preserve the existing separate brand PR, do not install or merge it into the ISO by default.
- **R-F05:** unreviewed root commands: only a human-controlled post-handoff execution phase may run build commands.

## Evidence accounting

- Existing M01 static/fixture CI and native ArchISO profile staging passed in [CI run 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858), with signed ArchISO 92-1. That result is **a source/profile gate only**.
- The repo-only edition contract passed GitHub Actions [run 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155).
- F02 package-layer source contract passed 11 tests in [CI run 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336) with no runtime package resolution or ISO build.
- No first Nemesis ISO, VM boot, Mac boot, install, package signing or release has been demonstrated.
- Active brand work exists in [PR #5](https://github.com/pskeffington/nemesis/pull/5); real Garuda theme validation is deferred and tracked separately.

## How to work now

Use [repository-phase Codex prompt](../codex/REPOSITORY_PHASE_PROMPT.md). F03 is the active next pass. Change repository source and documentation only, and run GitHub-hosted source tests. Do **not** follow `codex/BUILD_RUNBOOK.md` until F05 is approved. For accepted passes, report files/commit/CI/remaining gate; never mark a milestone accepted from a draft alone.
