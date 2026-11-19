# Codex executable pass queue

Every pass has one implementing owner and one observable gate. Sources refer to stable rows in [LITERATURE_MATRIX.md](../docs/research/LITERATURE_MATRIX.md). All generated evidence and ISO outputs stay local until sanitized.

| Pass | Owner | Inputs | Deliverable | Acceptance | Status |
| --- | --- | --- | --- | --- | --- |
| M01-P02 | build-qa-engineer | Existing scaffold, ARC-01..05 | verified staging/manifest tests, CI lint results | tests run and pass; errors documented | IN PROGRESS |
| M02-P01 | archiso-build-engineer | M01-P02, Arch/Garuda x86_64, network | ISO, SHA-256, build manifest/log | real mkarchiso exit 0 and checksum verified | NOT STARTED |
| M03-P01 | uefi-boot-validator | M02-P01, QEMU/OVMF | firmware-to-live-shell boot record | live shell and diagnostics observed | NOT STARTED |
| M04-P01 | intel-mac-compatibility | M03-P01 and non-T2 Intel Mac | physical device-compatibility sheet | external boot, no internal writes, return to macOS | BLOCKED on physical host |
| M05-P01 | distro-architect | M04-P01 | desktop/installer scoped ADR | selected installer safety and rollback reviewed | DEFERRED |
| M06-P01 | t2-platform-engineer | T2 research matrix and trusted package sources | T2 feasibility/security ADR | driver and signature provenance reviewed | DEFERRED |
| M07-P01 | asahi-platform-engineer | ARM rows and selected M-series Mac | separate ARM boot/installer ADR | boot-policy/recovery design approved | DEFERRED |

## M01-P02 — validate current scaffold
1. Run `git status --short`, inspect all scripts/manifest and installed archiso releng. Do not overwrite user changes.
2. Run `bash scripts/validate.sh` and record versions, failures and exit code. Include fixture tests and ShellCheck.
3. Stage a fresh profile using `bash scripts/prepare-profile.sh mac-intel /absolute/new/destination` and compare its boot files/manifest against installed releng.
4. Confirm overlay diagnostic binary is executable in resulting profile and packaged in image as required by profile permissions.
5. Commit only fixes and source evidence; label M01-P02 **ACCEPTED** only with actual passing local/CI checks.

## M02-P01 — build and checksum
1. Follow codex/BUILD_RUNBOOK.md; maintain separate ignored work/stage/out directories.
2. Capture build host architecture, archiso version, package versions and exact source commit.
3. Produce one new ISO with `mkarchiso`; reject ambiguous/stale artifacts and build errors.
4. Verify checksum from *inside* `out/mac-intel`. Log result outside Git.
5. Hand artifact/hash to UEFI validator. No physical compatibility claim.

## M03-P01 — virtual UEFI
1. Install QEMU and OVMF; locate firmware paths on host rather than assuming a distribution-specific one.
2. Use a throwaway VM with ISO attached read-only; preserve its log and note firmware version.
3. Reach kernel/live shell; execute `nemesis-hw-report`. Treat VM-reported devices as virtual only.
4. Record PASS/FAIL for each step; update roadmap only with observed results.

## M04-P01 — first Mac
1. Identify model + T2 status without serial; confirm backup, recovery path, external keyboard and safe removable drive.
2. Boot externally; run read-only inventory; test input/display/network, then other peripherals individually.
3. Document model-specific results as PASS/FAIL/PARTIAL/NOT TESTED and redacted proof.
4. Verify macOS still boots and internal partitions were not altered.

**Failure rule:** stop at the failing gate, preserve logs, open a focused defect and repair only the relevant component; do not proceed by relabeling outcomes. **Rollback:** revert source commit or safely discard *verified generated* directories, never internal Mac storage.
