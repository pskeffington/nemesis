# Nemesis — program roadmap (GitHub foundation phase)

**Effective 2026-11-19.** **Active phase: repository source, research, architecture and handoff preparation.** The current user directive is **no Linux-machine execution**. The [foundation priority plan](docs/FOUNDATION_PRIORITY_PLAN.md) governs F00–F06. Historical M-series milestones remain below as *future* execution gates.

## Current repository-only work queue

| Priority | Pass | Purpose | Owner agent | Gate | State |
| --- | --- | --- | --- | --- | --- |
| P0 | F00 | Baseline source/CI and upstream distro recon | distro-architect | versioned research and prior source CI | ACCEPTED |
| P0 | F01 | Edition and platform contract | distro-architect | `spec/editions.json` + GitHub source test | ACCEPTED — [CI 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155) |
| P0 | F02 | Package composition, manifest dependencies/conflicts | archiso-build-engineer | source-owned policy + deterministic checks | **READY — ACTIVE NEXT PASS** |
| P0 | F03 | Mac device/firmware support and compatibility evidence schema | intel-mac-compatibility | source-linked feature-level contract, no false PASS claims | READY |
| P0 | F04 | Build provenance, release security, recovery policy | security-release-reviewer | signed-source/rollback/artifact design review | NOT STARTED |
| P1 | F05 | Complete and approve Codex handoff packet | build-qa-engineer | all P0 gates + explicit user GO | NOT STARTED / NO-GO |
| P2 | F06 | Optional Nemesis icon/wallpaper/KDE theme | visual development branch | provenance, contrast and reversible UI review | PARALLEL; PR #5 open |

Source tests may run in GitHub Actions. Do not execute `mkarchiso`, QEMU, hardware diagnostics or Linux host provisioning in this phase. A draft/commit is not evidence of successful runtime behavior.

## Repo-phase milestone dependency

```text
F00 -> F01 -> F02
             \-> F03
F02 + F03 -> F04 -> F05 -> [explicit GO] -> M02
F06 is independent optional visual design; it does not gate M02.
M02 ISO -> M03 virtual UEFI -> M04 physical Intel Mac.
```

## Planned execution milestones — parked

| Milestone | Outcome | Required prior gate | Current status |
| --- | --- | --- | --- |
| M00 | Initial repo authority and source inspected | none | ACCEPTED |
| M01 | Intel ArchISO scaffold, source fixtures and real releng staging CI | M00 | ACCEPTED (source/profile only) |
| M02-P01 | Actual x86_64 non-T2 Intel Mac ISO compiled with portable SHA | F05 accepted **plus user GO** | **DEFERRED**, issue [#2](https://github.com/pskeffington/nemesis/issues/2) remains open |
| M03-P01 | ISO boots to live shell in x86_64 UEFI VM | M02 evidence | DEFERRED, [#3](https://github.com/pskeffington/nemesis/issues/3) |
| M04-P01 | External boot and feature-level acceptance on real non-T2 Intel Mac | M03 + test hardware and recovery | DEFERRED, [#4](https://github.com/pskeffington/nemesis/issues/4) |
| M05 | Safe accessible KDE/installer with macOS recovery plan | M04 | DEFERRED |
| M06 | T2-specific feasibility, firmware trust, physical acceptance | separate T2 policy/hardware | RESEARCH ONLY |
| M07 | Apple Silicon/Asahi ARM64 platform | distinct boot/installer safety | RESEARCH ONLY |
| M08 | Optional operator/RF editions | validated core and platform | DEFERRED |

## Current active pass contract — F02

- **Goal:** define a verifiable package-layer dependency, conflict and trust model before Codex implements any new image or optional edition.
- **Owner:** archiso-build-engineer; security-release-reviewer checks external source/trust policy.
- **Inputs:** `spec/editions.json`, `profiles/mac-intel/packages.x86_64`, `docs/research/UPSTREAM_DISTRO_RECON.md`.
- **Output:** machine-readable package layer policy, source-only validator and a source-backed decision on merge precedence and exemptions.
- **Acceptance:** GitHub tests pass; manifest references exist or are clearly marked planned; no unsigned third-party repo, silent T2/ARM cross-inclusion or unauthorized default desktop/operator packages.
- **Failure/rollback:** keep previous accepted edition contract; revert the failing spec/test commit; no machine cleanup.
- **Status:** READY, implementation work may proceed entirely in GitHub.

## Prior evidence and limits

- Source/fixture static CI and real installed ArchISO releng profile-staging CI passed on signed ArchISO **92-1**, [GitHub Actions 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858). It preserved EFI/GRUB/syslinux folders, pacman.conf, manifest uniqueness and diagnostic overlay.
- Comparative source review covered ArchISO, EndeavourOS, CachyOS, RebornOS, Garuda, t2linux and Asahi; see [source matrix](docs/research/UPSTREAM_DISTRO_RECON.md). A source-head SHA is not a tested runtime.
- New repo-only edition contract source test passed [run 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155).
- **No Nemesis ISO exists as an accepted artifact; no VM or Mac boot, installation, T2/ARM release or theme-on-Garuda session acceptance has occurred.**
- Separate visual work exists in [PR #5](https://github.com/pskeffington/nemesis/pull/5); its physical Garuda proof [issue #6](https://github.com/pskeffington/nemesis/issues/6) remains future work.

## Risks and authority

- **R-F01:** “build next” in older runbooks conflicts with current repository-only phase. This roadmap and [AGENTS.md](AGENTS.md) take precedence.
- **R-F02:** source CI cannot prove packages build or boot; keep source, built image, UEFI and physical evidence separate.
- **R-F03:** Broadcom, audio, camera, EFI, T2 and ARM coverage differs by model/SoC. Unknown remains unverified.
- **R-F04:** no unsigned/untrusted package feeds, proprietary Apple firmware bundling or internal disk write automation.
- **R-F05:** design/artwork is separate from core boot and security; no forced merge of active brand PR.

**Future transition:** only after F05 acceptance and explicit user instruction. The inactive [Linux execution prompt](codex/LINUX_EXECUTION_PROMPT.md) and [build runbook](codex/BUILD_RUNBOOK.md) remain reference material until then.
