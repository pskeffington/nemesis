# CI-only Docker ISO build validation

**User authorization, 2026-11-19:** use Docker to validate the **Nemesis x86_64 Intel ISO build** while continuing repository-side development. This is a **narrow exception** to the repository-only, source-test default. No user's Garuda/Linux workstation, Mac, SSH, firmware, disks, USB devices or physical hardware is touched.

## Boundaries

- Runs on an **ephemeral GitHub-hosted Ubuntu runner** using the runner's Docker daemon.
- Builder image uses official `archlinux:base-devel`, installs signed Arch packages (`archiso`, `grub`, `git`, `shellcheck`, `file`) in the container.
- The ArchISO build requires Docker `--privileged` for root filesystem/mount operations. This is constrained to **trusted main branch** pushes and explicit workflow dispatch; never execute on fork pull-request code or use privileged Docker on a personal workstation.
- GitHub checkout uses `persist-credentials: false`; job has `contents: read` permissions and passes no secrets to container. Generated work/out files are ignored by Git.
- The workflow does **not** run QEMU, install to disk, prepare USB, change Mac boot policies, or grant host execution permission in `codex/HANDOFF_CONTRACT.md`.
- The untested ISO is **not automatically published**; by default, only a small diagnostic evidence artifact is uploaded. Manual workflow dispatch can opt in to uploading an untested prototype ISO.

## Entrypoints

- [CI workflow](../.github/workflows/docker-archiso.yml)
- [Dockerfile](../docker/archiso/Dockerfile)
- [Container execution/inspection](../docker/archiso/validate-build.sh)
- Existing [ISO builder](../scripts/build-iso.sh) and [profile preparation](../scripts/prepare-profile.sh)

## Acceptance levels

| Level | Required observation | Claims allowed |
| --- | --- | --- |
| D0 Docker config | Dockerfile/workflow committed, syntax checks | Docker CI is configured (NOT built) |
| D1 Image bootstrapping | Docker image builds; Arch package signatures validated | Docker builder can install dependencies |
| D2 Real image assembly | `mkarchiso` exits zero and one new nonempty Nemesis ISO appears | ISO was **built in container**, not booted |
| D3 Artifact integrity | Portable SHA-256 sidecar validates from output folder | ISO checksum verified |
| D4 Boot metadata | `xorriso` reports a UEFI El Torito boot entry | ISO contains UEFI boot metadata **not** proof it boots |
| D5 Virtual boot | Separate future QEMU/OVMF run with observed kernel/live shell | UEFI VM boot accepted only with logs |
| D6 Physical Mac | Separate, explicitly approved model-specific external boot | Actual Intel Mac hardware accepted only with evidence |

## Workflow behavior

1. GitHub source checkout, runner resource reporting.
2. `docker build --pull` of official Arch-based builder (record package and runner versions).
3. `docker run --rm --privileged` with bind mount limited to ephemeral GitHub Actions checkout.
4. Inside Docker: source validation, installed-ArchISO releng staging, real `scripts/build-iso.sh mac-intel`.
5. Capture exit code and `mkarchiso` log; verify one ISO, checksum, file type and UEFI El Torito metadata.
6. Upload CI evidence (log, tool versions, hash) as a short-lived GitHub Actions artifact. ISO upload is opt-in and is never a release.

## Stop and rollback

If the build fails because of image package conflicts, resource exhaustion, mounts, package signatures or ArchISO profile drift, mark **Docker build blocked**, preserve logs and implement a minimal source fix in a new commit. Never disable pacman signatures or weaken failure detection to produce an artifact. Because the runner is ephemeral, there is no user-machine rollback, but the output is still explicitly **untrusted** until build and boot gates are satisfied.

## Source references

- ArchISO upstream [build documentation](https://github.com/archlinux/archiso/blob/master/README.rst)
- ArchISO [mkarchiso manual](https://man.archlinux.org/man/mkarchiso.1.en)
- Community reference [privileged Docker mkarchiso in GitHub Actions](https://github.com/marketplace/actions/mkarchiso)

**Repository-phase status:** this is a scoped Docker build test, **not** a broad switch to Linux deployment. The F03 Mac hardware policy and F04 release specification remain on the critical-path handoff plan.

## Initial CI evidence and control notes (2026-11-19)

- [Initial trusted Docker job 44610122687](https://github.com/pskeffington/nemesis/actions/runs/44610122687), source commit `cc93fd9f0b135d8f3847177f6fe6b056c1ba4a0c`. The **Docker image build** succeeded; the real `mkarchiso`/artifact validation gate must be judged from the eventual job result and evidence artifact, not from the image-creation step.
- An independent repository lint gate reported ShellCheck SC2129 for repeated append redirections in the evidence script; this was repaired in [PR #13](https://github.com/pskeffington/nemesis/pull/13), and the corrected branch passed [static checks](https://github.com/pskeffington/nemesis/actions/runs/44610495916). The correction groups log writes and does not change the ISO package/profile contents.
- Merging that nonfunctional cleanup used a single `[skip ci]` commit to avoid canceling the already-running expensive Docker build. This docs-only follow-up restores normal main-branch source CI without starting another Docker build. **Do not use CI skips as a substitute for source validation.**
- A GitHub-hosted runner has finite disk space; if full releng compilation exhausts space, record `BLOCKED_BY_RUNNER_RESOURCES` and either size a suitable disposable runner or design a separately labeled small smoke profile. Never mark a reduced profile as proof the full distribution assembled.

## Independent MacBook Air field ISO validation

A second trusted-main Docker workflow (`.github/workflows/docker-air-field.yml`) builds a distinct `nemesis-air` image using `scripts/prepare-air-field-profile.sh` and `scripts/build-air-field-iso.sh`. It adds only the optional official-package manifest and read-only `nemesis-field-check`. [F03-A02 issue #15](https://github.com/pskeffington/nemesis/issues/15) tracks [field Docker run 44612684836](https://github.com/pskeffington/nemesis/actions/runs/44612684836). Generic `mac-intel` ISO contents and tests are separate. A container build cannot establish UEFI boot, battery life, internal Wi-Fi, power policy suitability or MacBook Air hardware compatibility.

## Independent MacBook Air ISO evidence (2026-11-19)

- **First Air ISO:** [Docker run 44612684836](https://github.com/pskeffington/nemesis/actions/runs/44612684836) passed source `e1f12a48`: `nemesis-air-2026.11.19-x86_64.iso` (~1.3 GB), portable SHA-256 `OK`, UEFI El Torito metadata present; [evidence artifact #14573862782](https://github.com/pskeffington/nemesis/actions/runs/44612684836/artifacts/14573862782). No ISO binary was uploaded.
- **Hardened Air ISO:** [source 0257b09](https://github.com/pskeffington/nemesis/commit/0257b09bc03cc55b0931b411372af126ae8efbe5) adds SSH/ModemManager disabled auto-start, D-Bus alias removal, a mask and compiled-SquashFS checks. [Docker run 44614544328](https://github.com/pskeffington/nemesis/actions/runs/44614544328) was pending when this entry was written. A build PASS on the older source cannot be reused for the hardened revision.
- **Hardware:** no VM/physical Air boot, battery endurance, Wi-Fi, USB receiver, suspend or install tests yet.
