# Build and verification — Mac Intel edition

## Prerequisites

Use an updated **x86_64 Arch Linux or Garuda Linux host** with Internet, sudo, free space and installed `archiso`. Nemesis does not build an x86_64 ArchISO natively on macOS; use an Arch-family host or x86_64 VM.

```bash
sudo pacman -Syu --needed git archiso shellcheck
git clone https://github.com/pskeffington/nemesis.git
cd nemesis
bash scripts/validate.sh
sudo bash scripts/build-iso.sh mac-intel
```

Validation includes Bash syntax, package manifest checks, ShellCheck (when installed), a **fixture releng profile staging test** and a **relative SHA-256 portability/corruption test**. If ShellCheck is unavailable, the script says NOT RUN; the complete static gate has not passed.

## Profile staging, isolation and root safety
- Normal builder copies `/usr/share/archiso/configs/releng` into ignored `.build/profile-mac-intel` and leaves ArchISO's installed files untouched.
- `ARCHISO_RELENG_PROFILE` override is used **only by trusted fixtures** in tests. Real builds use installed releng; don't pass unreviewed profile trees to a root process.
- Build refuses existing staging/work directories, symlinked build/out dirs and pre-existing matching ISO filenames. Inspect generated paths before manual cleanup.
- ISO images and worktrees remain under `out/` and `.build/`, excluded from Git.

## Portable checksum and verification
The build script calls `scripts/write-checksums.sh` after a real `mkarchiso` exit 0. It requires **exactly one non-empty ISO**, writes the SHA-256 using a *relative filename*, and verifies it from the output directory.

```bash
cd out/mac-intel
ls -lh nemesis-*-x86_64.iso
sha256sum -c nemesis-*-x86_64.iso.sha256
```

No artifact is accepted merely because a stale ISO exists or a hash was generated.

## Acceptance ladder

| Check | Command / method | Required evidence |
| --- | --- | --- |
| Source validation | `bash scripts/validate.sh` | Bash syntax, ShellCheck, package and fixture tests |
| Profile staging | `scripts/prepare-profile.sh mac-intel ABSOLUTE_DESTINATION` | releng profile with Nemesis overlay, deduplicated manifest and permissions |
| Real ISO execution | `sudo bash scripts/build-iso.sh mac-intel` | mkarchiso exit code 0, one new ISO and matching SHA |
| VM boot | UEFI QEMU + OVMF | boot kernel/live shell and run diagnostics; **not physical Mac proof** |
| Physical Mac | non-T2 Intel external boot | model/driver matrix; no internal drive changes; return to macOS |
| Release | docs/RELEASE_GATES.md | all stage evidence and security approval |

## Virtual boot and physical safety
Install QEMU and `edk2-ovmf` on Arch/Garuda when the ISO build passes. Locate actual firmware paths with `pacman -Ql edk2-ovmf`, rather than assuming distribution paths. Use a throwaway UEFI VM, ISO read-only, and retain console logs.

For a physical test, first establish Mac model, backup, recovery access and removable media identity. Use Apple Option/Alt Startup Manager where appropriate; test peripherals individually and record redacted IDs only. Initial boot checks are read-only relative to internal Mac drives. T2 and Apple Silicon require separate boot and security approval.

## Evidence manifest template
See [release gates](RELEASE_GATES.md) and [Mac physical test template](research/MAC_TEST_REPORT_TEMPLATE.md). Report tested commands, host/package versions, ISO hash, actual QEMU/physical Mac observations, open defects and decision. Never commit binary ISO images or raw device-identifying logs.
