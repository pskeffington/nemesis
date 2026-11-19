# Intel Mac ISO — build operator runbook

**Host:** x86_64 Arch Linux/Garuda Linux. **Output:** one Nemesis ISO in ignored `out/mac-intel/`. **Target:** Intel non-T2 only. No installer or partition writer is run.

## 1. Prepare and inspect
```bash
sudo pacman -Syu --needed git archiso shellcheck
git status --short
uname -m
pacman -Q archiso linux-firmware 2>/dev/null || true
bash scripts/validate.sh
```

Do not build when validation failed. Confirm free space/network. Inspect `scripts/build-iso.sh`, `scripts/prepare-profile.sh`, `scripts/write-checksums.sh` and package manifest before sudo.

## 2. Execute real build and retain log
```bash
mkdir -p "$HOME/nemesis-evidence"
set -o pipefail
sudo bash scripts/build-iso.sh mac-intel 2>&1 | tee "$HOME/nemesis-evidence/first-iso.log"
```

Builder refuses existing work/staging directories, symlinked outputs and stale Nemesis ISO. Inspect those paths before manual cleanup. Generated ISO/logs must not go into Git.

## 3. Inspect and verify portable sidecar
```bash
cd out/mac-intel
ls -lh nemesis-*-x86_64.iso
sha256sum -c nemesis-*-x86_64.iso.sha256
```

Collect source commit, host/kernel, archiso version, package versions, UTC timestamp, ISO name/SHA-256, actual exit code and sanitized errors.

## 4. Handoff
Pass the ISO path and hash to `uefi-boot-validator`. Update ROADMAP.md with *build status only*. A checksum is not a boot test.

Stop on package-signature failure, unexpected privilege/disk writes, changed releng schema, missing dependencies, failed mkarchiso, ambiguous output or checksum mismatch. Preserve diagnostic work for focused repair; do not weaken pacman signature verification.
