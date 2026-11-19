# Nemesis — Codex and contributor contract

**Authority:** This GitHub repository owns Nemesis distro source, profile deltas, scripts, reproducibility documentation, the hardware evidence matrix and release criteria. Read README.md, ROADMAP.md and docs/ARCHITECTURE.md before editing. The separate linux_config repository is for host-specific configuration and is not copied into ISO images without review.

## Agent dispatch
- Role index: [agents/README.md](agents/README.md). Roles are written instructions for task delegation, not active background agents.
- Codex entry: [CODEX_KICKOFF.md](CODEX_KICKOFF.md); [session prompt](codex/SESSION_PROMPT.md); [pass queue](codex/PASS_QUEUE.md).
- Literature authority: [docs/research/LITERATURE_MATRIX.md](docs/research/LITERATURE_MATRIX.md); [method](docs/research/METHODOLOGY.md); [model candidates](docs/research/INTEL_MAC_CANDIDATES.md); [distro source recon](docs/research/UPSTREAM_DISTRO_RECON.md).
- One implementation owner/pass. Research and security can independently review but cannot approve unrun build/physical tests.
- External distro repositories are **read-only references** by default: inspect canonical source/revision, license and targeted paths; reuse a pattern only after an independent Nemesis implementation and test. Never copy a mirror's kernel/package repository by assumption.

## Hardware scope
1. **mac-intel**: x86_64 Intel Macs without T2; current *candidate* baseline uses stock installed ArchISO releng.
2. **mac-t2**: separate future kernel and firmware workflow. Never assume stock profile makes built-in T2 input/audio/wireless functional.
3. **mac-asahi**: independent Apple Silicon ARM64 boot stack. The x86_64 ISO cannot boot M-series Macs.
4. **operator layers**: optional packages for engineering, RF and security after core hardware acceptance; avoid unnecessary base ISO bloat.

## Non-negotiable safety
- No automatic repartitioning, internal-drive formatting, filesystem write, firmware extraction, disabling Apple startup security, or remote boot policy changes.
- No unauthorized Apple firmware redistribution, unsigned third-party release repos, hard-coded credentials, proprietary capture dumps, secrets, serial numbers, network identity or personal logs in public Git.
- Reject unreviewed `SigLevel = Never` in package sources. Model-specific Broadcom driver choice starts with actual PCI IDs; no universal `broadcom-wl`.
- Maintain GPL-3.0 repository LICENSE and check dependency/firmware rights separately.
- Keep ISO, rootfs worktrees, local logs and VM images out of version control. Do not put commercial valuation or pricing in this repository.
- Preserve user changes and accepted milestones; no destructive cleanups or force-push.

## Repeatable pass contract
1. Inspect baseline (`git status --short`, current branch, source matrix, previous acceptance evidence).
2. Name pass ID, goal, owner, files, source rows, expected output, failure/rollback and acceptance command.
3. Change one coherent unit; keep scripts fail-fast (`set -euo pipefail`), human-readable comments and source anchors.
4. Execute `bash scripts/validate.sh` and relevant real build/VM/physical tests when available. Record exact commands and exit codes.
5. Source commit != ISO build; ISO build != VM boot; VM boot != Apple physical boot; driver loaded != peripheral functional.
6. Update ROADMAP.md, decisions/matrix as needed, and hand off `Pass | files | command/result | evidence | status | next`.
7. When blocked, document why and select the highest-priority independent READY pass; do not invent success or skip a failed gate.

Default active work is M01-P04 native ArchISO packaged-releng staging CI and M01-P02 gate closure, then M02-P01 real ISO build on x86_64 Arch/Garuda. Source recon M01-P03 has been documented.
