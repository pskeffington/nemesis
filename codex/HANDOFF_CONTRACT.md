# Nemesis Linux execution handoff — future gate, not current assignment

**Mode:** `REPO_FOUNDATION` active. **Execution status:** `HOLD`. This file defines what must be ready before authorizing a later Codex session on a Linux machine; it is not an instruction to do so now.

## 1. Preconditions before any execution GO

- [ ] F02 package composition/official signed-source policy approved.
- [ ] F03 per-model Intel hardware/firmware/boot exclusions approved; T2 and ARM64 separate.
- [ ] F04 build/release provenance, artifact evidence and safety design approved.
- [ ] Current main commit and all linked CI statuses recorded; no unresolved P0 release/security defects.
- [ ] Scope agreed: first attempt **x86_64 Intel non-T2** image, not a T2/Asahi installation.
- [ ] Build host platform and prerequisites documented; do not assume a fresh Garuda installation contains archiso, ShellCheck, QEMU, or required utilities.
- [ ] Worktree changes reviewed before Codex touches the target machine.
- [ ] Human explicitly requests the phase transition and authorizes any machine-side actions. No preapproval is implied by having a runbook.

## 2. Required handoff packet (fill only from observed facts)

| Field | Value |
| --- | --- |
| Repository | `pskeffington/nemesis` |
| Branch and exact commit SHA | TO PIN AT HANDOFF |
| Approved edition | `mac-intel` (target only) |
| Approved profile and package manifest | `profiles/mac-intel` / `packages.x86_64` |
| Architecture decisions | `docs/DECISIONS.md` + F02/F03/F04 approvals |
| CI source proof | Link to accepted head runs |
| Build host OS/architecture | TO VERIFY ON LINUX |
| Available disk space/network | TO VERIFY ON LINUX |
| Root/privilege scope | TO APPROVE (never implicit) |
| Build output destination | Existing repository `out/mac-intel`, review target |
| Signed package sources | Official Arch by default; exception register if any |
| Mac test model | UNSELECTED, not needed to compile first ISO |
| Backup/recovery/access plan | REQUIRED BEFORE PHYSICAL TEST |
| Rollback / stop conditions | As below; review again at execution |
| GO / NO-GO decision | **NO-GO — current repository-only phase** |

## 3. Ownership and staged actions after explicit GO

**Operator:** archiso-build-engineer. **Independent reviewers:** build-qa-engineer and security-release-reviewer.

Stages are independent. At each stage record evidence and stop on failure; do not automatically advance from ISO to UEFI to Mac:
1. **Read-only preflight:** compare target host and pinned repo commit, verify clean worktree, ArchISO source, storage, signed repositories and available test dependencies.
2. **Source/static checks:** execute existing `scripts/validate.sh` and `tests/test-installed-releng.sh` on the approved host, record package versions.
3. **ISO build (requires explicit authorized privilege):** follow `codex/BUILD_RUNBOOK.md`; collect exact `mkarchiso` status, ISO hash, source provenance and redacted logs.
4. **UEFI virtual boot (new approval after build):** follow M03, UEFI OVMF evidence only.
5. **Physical Mac (separate new approval):** confirm exact device, backup, external media, manual boot and return to macOS; do not alter partitions in initial test.

## 4. Forbidden automatic behaviors

- No unattended root package installation or build execution in current repo-only phase.
- No assumed access to a user workstation, SSH, Mac firmware, partitions or USB targets.
- No forced cleanup of user directories, default sudo, destructive hardware writes or firmware extraction.
- No insecure package signing exceptions, hard-coded credentials or uploading unredacted machine data.
- No merging unrelated visual/brand PR into core boot profile to “make progress.”
- No declaring hardware compatibility on source CI, build success or virtual boot alone.

## 5. Required reporting contract

`Pass ID | exact source commit | host/version details when actually observed | changed paths | commands and real exit statuses | hashes/log links | acceptance (PASS/FAIL/NOT RUN) | blockers | next approved pass`.

A handoff is accepted when the source authority, dependency and safety decisions are complete, CI is green, the operator can reproduce the intended first step, and the human explicitly approves execution. Do not turn a pending check box into a check mark on assumption.

## 6. Docker CI evidence is not workstation approval

The separately authorized [GitHub-hosted Docker build validation](../docs/DOCKER_ISO_VALIDATION.md) may establish an ISO assembly and checksum result for one source commit. It does **not** satisfy the human-controlled phase transition, specific Garuda host preflight or privilege approval, QEMU VM boot, physical Mac boot, installer or release gates. Any Docker run must be linked by immutable commit and actual CI result; do not substitute its artifact for an accepted Mac hardware test.

## Air field target gate

Prefer non-T2 MacBookAir7,2 then 6,2/6,1 for future supervised acceptance; model/PCI ID, battery health, offline USB-network fallback and safe recovery must be recorded. The optional Air field source layer is **not a built image** and does not permit workstation access. See `docs/FIELD_LAPTOP_ARCHITECTURE.md` and `codex/MACBOOK_AIR_FIELD_PASS.md`.
