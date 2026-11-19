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

## ADR-006 — Compare distro sources without wholesale imports (2026-11-19)
**Decision:** treat EndeavourOS, CachyOS, Garuda, RebornOS, T2 and Asahi implementations as source-pinned architectural precedents. Keep official ArchISO as Nemesis build substrate. Require license/package trust, CPU baseline and platform-specific review before importing code or dependencies.

**Reason:** related distros solve different installer, performance, boot and firmware constraints. A successful upstream design is not a validated Nemesis component.

**Consequence:** record inspected commit/path, take design patterns rather than blindly copy source, and gate all new components by direct tests. See docs/research/UPSTREAM_DISTRO_RECON.md.

## ADR-007 — Native ArchISO profile compatibility CI (2026-11-19)
**Decision:** supplement Ubuntu Bash/ShellCheck fixtures with a native Arch Linux container job installing real packaged archiso and staging releng.

**Reason:** a synthetic fixture cannot detect actual upstream boot/profile schema drift. The Arch job is a contract test, not a costly privileged image build.

**Consequence:** keep M02 real mkarchiso and M03 UEFI boot as distinct gates. When upstream releng changes, diagnose and update the staging contract rather than loosening it. **Acceptance evidence:** run 44607322858 passed on 2026-11-19 with signed ArchISO 92-1; no actual ISO build was performed.

## ADR-005 — No automatic Mac disk or firmware writes
**Decision:** building, diagnostics and initial boot acceptance are read-only relative to internal Mac drives. Installer work requires a separate explicit safety review.

**Reason:** protect macOS recovery, firmware state and data, particularly on legacy hardware.

## ADR-008 — Repository-first foundation before machine execution (2026-11-19)
**Decision:** current mode is `REPO_FOUNDATION`; prioritize package composition, Mac hardware design, release/security architecture and explicit handoff instructions. Keep all `mkarchiso`, QEMU, USB and physical Mac execution deferred until P0 specification gates pass and the user explicitly authorizes Linux execution.

**Reason:** a green CI source/profile test is not a complete distro specification or an instruction to touch a workstation. A coherent contract must precede hardware execution.

**Consequences:** `docs/FOUNDATION_PRIORITY_PLAN.md` and `codex/REPOSITORY_PHASE_PROMPT.md` supersede older “build next” language. Existing build runbooks remain future references. The theme PR is optional and isolated.

## ADR-009 — Package design is a source contract, not a runtime resolver (2026-11-19)
**Decision:** version package-layer ordering, graph dependencies, conflict policy, repository trust and platform exclusions in `spec/package-layers.json`, while leaving `scripts/prepare-profile.sh` unchanged. Default official signed Arch packages; no AUR/firmware auto-install and no T2/ARM crossover.

**Reason:** a stable, testable specification should precede generalized package-composition code or execution permissions.

**Consequence:** F02 accepted as repo-only design after [11 Python CI tests](https://github.com/pskeffington/nemesis/actions/runs/44608516336). No package resolver or ISO was run. F03 hardware policy is the next source-only gate.

## ADR-010 — Isolated Docker build CI exception (2026-11-19)
**Decision:** permit a real `mkarchiso` x86_64 Intel ISO build only inside a trusted **GitHub-hosted ephemeral Docker container** as F02-V01, per explicit user request. Use the official Arch base image, signed packages, `--privileged` limited to the disposable runner, no persisted checkout credentials and only default small evidence uploads.

**Reason:** prove that the committed profile and scripts produce a real bootable-media *artifact* before handing a distro build to local Garuda, without using the user's workstation.

**Scope:** [Docker validation runbook](DOCKER_ISO_VALIDATION.md) and [issue #12](https://github.com/pskeffington/nemesis/issues/12). A passing build/hash/El Torito metadata proves **assembly**, not UEFI boot, Mac drivers, installer safety or a release; local hardware phase remains NO-GO.

## ADR-011 — MacBook Air field-laptop first, optional and conservative (2026-11-19)
**Decision:** prioritize Intel MacBookAir7,2, 6,2 and 6,1 before other Mac form factors. Introduce a separately selected source layer of signed Arch tools, read-only battery/thermal/wireless inventory and a model-level acceptance matrix. Do not change the Docker-verified rescue image, load a universal Broadcom `wl` driver, enable competing power daemons, override fans, or apply aggressive USB autosuspend by default.

**Reason:** older Air laptops have limited memory/storage, Broadcom network dependencies, no built-in wired Ethernet and potentially fragile USB, sleep and battery behavior. Field reliability and offline recovery must precede cosmetic tuning or RF tool volume.

**Consequence:** F03-A source tests accepted in GitHub, with a separate pending optional profile-integration gate. ISO/VM/Mac field results remain unverified. See `docs/FIELD_LAPTOP_ARCHITECTURE.md`.
