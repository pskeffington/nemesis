# Intel Mac ISO — build operator runbook

**Host:** x86_64 Arch Linux/Garuda Linux. **Output:** one Nemesis ISO in ignored `out/mac-intel/`. **Target:** Intel non-T2 only. No installer or partition writer is run by this procedure.

## 1. Prepare and inspect

```bash
sudo pacman -Syu --needed git archiso shellcheck
git status --short
uname -m
pacman -Q archiso linux-firmware 2>/dev/null || true
bash scripts/validate.sh
```

Do not run build if the preceding validation failed. Confirm free space and network connectivity. Read ``scripts/build-iso.sh`, ``scripts/prepare-profile.sh` and the manifest before invoking as root.

## 2. Execute real build with a retained log

```bash
mkdir -p "$HOME/nemesis-evidence"
set -o pipefail
sudo bash scripts/build-iso.sh mac-intel 2>&1 | tee "$HOME/nemesis-evidence/first-iso.log"
```

The script refuses to reuse existing work/staging directories or a pre-existing Nemesis ISO. Inspect the paths before manual cleanup; never run blind recursive deletion against user-supplied paths.

## 3. Inspect artifacts and verify portable checksums

```bash
cd out/mac-intel
ls -lh nemesis-*-x86_64.iso
sha256sum -c nemesis-*-x86_64.iso.sha256
```

Collect: source commit, host/kernel, ArchISO version, package manifest, UTC build timestamp, output file, SHA-256, actual exit status, errors. Do not commit the ISO or raw log.

## 4. Handoff

Tell `uefi-boot-validator` the exact artifact path, SHA-256 and tool versions. Update ROADMAP.md with **build status only**. A checksum verification is not a boot test.

**Stop conditions:** package signature failure, unexpected privilege/disk writes, missing upstream profile schema, failed mkarchiso, ambiguous output or checksum mismatch. Keep working directory and logs for diagnosis; no automatic recovery via unsafe pacman options.
