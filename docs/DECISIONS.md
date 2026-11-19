# Architecture decisions

## ADR-001 — Mac-first, Intel non-T2 first (2026-11-19)
**Decision:** prioritize 64-bit Intel Macs without T2 security chip; create a Mac-focused ArchISO-derived image before desktop specialization.

**Reason:** official Arch media already targets Intel Macs. This gives a testable EFI/driver baseline and is a practical recovery path for aging Intel Mac hardware.

**Consequence:** physical model compatibility cannot be inferred from generic Arch compatibility; record observed results.

## ADR-002 — Keep T2 separate
**Decision:** no implicit T2 claim in `mac-intel`. Research an independently validated T2 kernel, input/audio stack and firmware workflow.

**Reason:** upstream t2linux documents additional hardware patches, firmware and secure-boot requirements.

**Consequence:** T2 edition is deferred until reproducible build and hardware evidence exist.

## ADR-003 — Apple Silicon requires an ARM64 platform lane
**Decision:** do not create an ARM64 edition by repackaging x86_64 archiso. Conduct an Asahi platform survey and independent build/boot design first.

**Reason:** boot chain, kernels, drivers and firmware are substantially different; Apple Silicon cannot boot the initial ISO.

**Consequence:** no Apple Silicon release is announced or implied.

## ADR-004 — Build from installed upstream ArchISO
**Decision:** copy installed `/usr/share/archiso/configs/releng` to ignored staging, apply package delta and overlay, invoke `mkarchiso`.

**Reason:** track official Arch rescue/install behavior without copying a large, rapidly changing upstream tree into this repository.

**Consequence:** record archiso version and resulting ISO SHA for every build; build is currently not bit-for-bit pinned.

## ADR-005 — No automatic Mac disk or firmware writes
**Decision:** building, diagnostics and initial boot acceptance are read-only relative to internal Mac drives. Installer work requires a separate explicit safety review.

**Reason:** protect macOS recovery, firmware state and data, particularly on legacy hardware.
