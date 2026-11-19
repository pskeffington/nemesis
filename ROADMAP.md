# Nemesis — Mac-first distro delivery roadmap

Statuses: `NOT STARTED`, `READY`, `IN PROGRESS`, `BLOCKED`, `REVIEW`, `ACCEPTED`, `DEFERRED`.

**Goal:** deliver a verified, recoverable Arch-based live/install experience on a documented set of Intel Macs, then expand through separate T2 and Apple Silicon hardware gates.

| ID | Outcome / acceptance checkpoint | Prerequisite | Status |
| --- | --- | --- | --- |
| M00 | Repository authority and baseline identified | Existing main branch | ACCEPTED (initial source inspected) |
| M01 | Mac-first hardware architecture, overlay builder, lint and documentation committed | M00 | IN PROGRESS (source created; execution evidence pending) |
| M02 | ISO builds on an Arch/Garuda x86_64 host; output and checksums recorded | M01 | NOT STARTED |
| M03 | Generated ISO boots in x86_64 UEFI QEMU; shell and network observed | M02 | NOT STARTED |
| M04 | Non-T2 Intel Mac boots externally; hardware audit and recovery path documented | M03 + test hardware | NOT STARTED |
| M05 | Desktop/installer and post-install integration validated without harming macOS | M04 | NOT STARTED |
| M06 | T2-specific signed-off feasibility, kernel and firmware workflow | Separate T2 test Mac | DEFERRED |
| M07 | Apple Silicon ARM64 feasibility and Asahi-compatible boot strategy | Platform research and supported test Mac | DEFERRED |
| M08 | RF/field-operator editions as optional layers, not core ISO requirements | M05 | DEFERRED |

## Pass queue

### M01-P01 — Mac-first foundation
- **Deliverables:** README.md, docs/ARCHITECTURE.md, docs/MAC_COMPATIBILITY.md, scripts, mac-intel overlay, static CI and this roadmap.
- **Acceptance:** files committed, syntax and lint checks recorded.
- **Failure/rollback:** revert scaffold commit; no host disk state is modified.
- **Next:** run lint and prepare profile against installed ArchISO on Garuda.

### M02-P01 — Reproducible first ISO
- **Precondition:** Arch or Garuda x86_64 build host, current `archiso`, adequate disk space and network.
- **Steps:** run `bash scripts/validate.sh`; `sudo bash scripts/build-iso.sh mac-intel`; inspect logs, ISO filename and SHA-256.
- **Gate:** mkarchiso exits 0; generated image exists and `sha256sum -c` passes; logs kept outside Git.
- **Evidence:** build host, archiso version, commit SHA, command, ISO checksum and result.
- **Rollback:** delete generated `.build/` and `out/` only after verifying intended paths.

### M03-P01 — VM firmware/boot probe
- **Precondition:** M02 accepted and OVMF available.
- **Gate:** UEFI firmware detects ISO, kernel and live shell boot, `nemesis-hw-report` runs, logs retained.
- **Limit:** virtual success does not establish Apple physical hardware compatibility.

### M04-P01 — Physical Mac acceptance
- **Precondition:** non-T2 Intel Mac, verified backup, external boot/recovery media, ISO from M02.
- **Gate:** external UEFI boot, display and keyboard, at least one network path, storage discovery, no internal disk changes.
- **Evidence:** Mac model identifier (no serial), firmware/CPU, kernel, device IDs, works/fails matrix, rollback result.
- **Stop:** boot failures, missing input, unexpected disk access or unstable thermals must be documented before installation work.

### M05-P01 — Installable desktop edition
- **Gate:** desktop login, Wi-Fi/Bluetooth, trackpad, display HiDPI, audio, suspend/resume, updates, recovery and installer dry-run checks; dual-boot actions require explicit user approval.
- **Dependency:** verified device support. No automatic wipe scripts.

## Risks / decisions
- **R01:** T2 devices need nonstandard support; maintain a separate lane rather than silently mixing kernels.
- **R02:** Broadcom Wi-Fi differs by model; do not bundle `broadcom-wl` universally or redistribute Apple firmware.
- **R03:** EFI/USB boot and 32-bit EFI exceptions vary; record model-specific tests.
- **R04:** Apple Silicon is ARM64 with a distinct boot chain; M-series ISOs are outside initial scope.
- **R05:** Rolling Arch updates can change package and archiso behavior; capture versions and checksums per build.
- **R06:** Build scripts run as root on a trusted Arch-family host; inspect changes and never run unreviewed forks.

## Evidence register
- 2026-11-19: repository originally contained README.md and GPL-3.0 LICENSE; non-T2 Intel Mac chosen as first build target.
- No actual ISO build, UEFI VM boot or Mac physical test has yet been observed in this repository.
