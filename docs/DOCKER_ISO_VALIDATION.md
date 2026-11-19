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
