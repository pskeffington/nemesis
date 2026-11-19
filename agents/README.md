# Nemesis engineering agent roster

**Current mode: repository-only foundation.** F02 package composition, F03 hardware design, F04 release policy and F05 approved handoff are the critical path. Do not assign agents workstation setup, ISO compilation, QEMU or Mac hardware work yet. See [foundation priority plan](../docs/FOUNDATION_PRIORITY_PLAN.md).

These are **versioned role instructions for Codex and human contributors**, not automatically running background processes. Start with root [AGENTS.md](../AGENTS.md), then assign one role to an explicit pass in [codex/PASS_QUEUE.md](../codex/PASS_QUEUE.md).

| Role file | Responsibility | Produces |
| --- | --- | --- |
| [distro-architect.md](distro-architect.md) | System architecture and ADR gate | architecture diff / decision record |
| [archiso-build-engineer.md](archiso-build-engineer.md) | Releng overlay, package delta, ISO assembly | reproducible script and build evidence |
| [uefi-boot-validator.md](uefi-boot-validator.md) | UEFI image, VM, recovery and boot-chain checks | boot-test evidence |
| [intel-mac-compatibility.md](intel-mac-compatibility.md) | Intel non-T2 device inventory and drivers | physical feature matrix |
| [t2-platform-engineer.md](t2-platform-engineer.md) | T2 kernel/firmware integration research | feasibility decision; no unreviewed release |
| [asahi-platform-engineer.md](asahi-platform-engineer.md) | M-series ARM64/Asahi platform assessment | separate ARM ADR and SoC matrix |
| [evidence-librarian.md](evidence-librarian.md) | Literature matrix, source conflicts and provenance | source-to-test traceability |
| [security-release-reviewer.md](security-release-reviewer.md) | Package signatures, firmware rights, privacy and release | accept/reject safety review |
| [build-qa-engineer.md](build-qa-engineer.md) | Deterministic tests, CI and artifact verification | acceptance log and test defects |
| [upstream-distro-recon.md](upstream-distro-recon.md) | Comparable Arch/Mac distro source reconnaissance | pinned source matrix and adoption gates |

## Dispatch and handoff

**One active implementation owner per pass.** Literature and security reviewers can run in parallel only on independent files. No agent may declare another agent's unrun gates passed.

Every handoff reports: `Pass ID | goal | paths changed | exact checks and results | actual log/hash/commit | open defects | acceptance status | next pass`.

Stop for missing core boot input, altered partition/firmware state, unsigned third-party release packages, leaked secrets or unexpected root filesystem changes. Keep research/output logs outside the public repo until redacted.

See [Codex kickoff](../CODEX_KICKOFF.md) and [session prompt](../codex/SESSION_PROMPT.md).
