# Nemesis — comparable distro repository reconnaissance

**Review date:** 2026-11-19. Inspected GitHub repository metadata, branch heads, selected README/build/profile paths and upstream docs. Garuda canonical ISO profiles were inspected on GitLab. **This is source reconnaissance, not execution or Mac hardware acceptance.**

## Source-pinned comparative matrix

| ID | Repository and inspected paths | Reviewed head | License reported | Useful design pattern | Nemesis adoption decision |
| --- | --- | --- | --- | --- | --- |
| UP-01 | [ArchISO](https://github.com/archlinux/archiso): `configs/releng/profiledef.sh`, `packages.x86_64`, `docs/README.profile.rst` | `master@8e3ead17e1e5` | GPL-3.0 | Official profile, `airootfs`, package manifest, systemd-boot UEFI and `file_permissions` contract | **ADOPT:** preserve packaged upstream releng; test actual installed profile, not only synthetic fixtures |
| UP-02 | [EndeavourOS ISO](https://github.com/endeavouros-team/EndeavourOS-ISO): `README.md`, `prepare.sh`, `airootfs` | `main@90376d8f52ab` | GPL-3.0 | KDE live environment, separate installer/Calamares fork, stable release tags and extensive patched ArchISO | **STUDY:** separate installer and rescue/live image; **NO** imported modified `mkarchiso` or packages |
| UP-03 | [CachyOS Live ISO](https://github.com/CachyOS/CachyOS-Live-ISO): `README.md`, `archiso`, `buildiso.sh`, `testiso.sh`, `.github/workflows/build.yml` | `master@b0ebcae291b1` | GPL-3.0 | Desktop profile, CI Arch container builds, artifact/checksum management and test scripts | **ADOPT PATTERN:** independent staging/build/boot/release gates; do not impose newer-CPU optimization on old Intel Macs |
| UP-04 | [Garuda canonical profiles](https://gitlab.com/garuda-linux/tools/iso-profiles) and [garuda-tools GitHub mirror](https://github.com/garuda-linux/garuda-tools): manifests and overlays, `README.md` | GitLab revision not pinned; GitHub mirror `deployiso@433ad847905a` | Mirror SPDX license not established | Edition/flavour-specific package lists, overlays, CI build selection | **ADOPT STRUCTURE** for future optional editions; do not import Garuda packages or host config into Nemesis core |
| UP-05 | [RebornOS ISO](https://github.com/RebornOS-Team/rebornos-iso): `README.md`, `configs/releng`, `scripts/update_releng_branch.sh` | `main@7bca07af5289` | GPL-3.0 | Explicit upstream-releng merge maintenance | **ADOPT** upstream-drift checking; **REJECT** optional `SigLevel = Optional TrustAll` example in release builds |
| UP-06 | [t2linux archiso-t2](https://github.com/t2linux/archiso-t2): `README.md`, `build.sh`, `archiso` | `senpai@f20577d5a432` | GPL-3.0 | T2-patched kernel and first-login Apple BCM firmware fetcher reading macOS APFS | **RESEARCH ONLY:** T2 separate, no automated APFS extraction or firmware redistribution |
| UP-07 | [t2linux EndeavourOS T2](https://github.com/t2linux/EndeavourOS-ISO-t2): profile and package manifests | `senpai@28a36b6fa6f3` | GPL-3.0 | Maintained downstream adaptation of an installer image to T2 hardware | **STUDY:** separate platform build, trusted dependency and physical test gates |
| UP-08 | [Asahi installer](https://github.com/AsahiLinux/asahi-installer): `README.md`, `src`, `scripts`, `.github/workflows` | `main@e93743d52178` | MIT | M-series installer, `m1n1` boot chain, downstream installer metadata/OS image paths | **RESEARCH ONLY:** independent ARM64 boot, storage-consent and recovery workflow; not x86_64 ArchISO |

**Snapshot interpretation:** branch SHAs are observed source HEADs retrieved 2026-11-19, not validated release tags or Arch package locks. Only selected paths were inspected, not a full code audit. GitHub mirrors and unofficial forks must not be mistaken for a canonical release source.

## Decision matrix and implementation queue

| Technical question | Finding | Decision | Acceptance test |
| --- | --- | --- | --- |
| Core image source | ArchISO official releng is smaller than downstream full-stack distro forks | Keep Nemesis as thin package/overlay delta on signed, installed releng | Real packaged profile stages with preserved boot files |
| Installer packaging | EndeavourOS separates KDE live session and Calamares; Asahi has its own ARM boot/installer | Defer graphical installer until boot, hardware, recovery tests pass | Installer design ADR, VM dry-run and Mac-specific acceptance |
| Edition packages | Garuda flavours and CachyOS profiles explicitly separate image choices | Future Mac desktop and field-operator variants are layers, not core dependencies | Per-profile manifests plus verified hardware performance |
| CI quality | CachyOS uses a real Arch container; Nemesis currently only had Ubuntu fixture CI | Add an **Arch Linux packaged-releng** staging job without privileged ISO build | Job runs script against installed ArchISO and checks UEFI assets |
| Upstream version drift | RebornOS tracks releng updates; ArchISO profile schema can evolve | Capture installed package revision and test real schema on each push | Arch staging CI with source-profile hash and boot-file comparison |
| Kernel/firmware policy | T2 images require other kernel and firmware workflows | Do not mix T2 into baseline Intel image | Signed package provenance and physical T2 test |
| Platform boot | Apple Silicon installer does not use ordinary Intel EFI boot | Explicit ARM64 lane; no general “USB-only no internal change” promise | Model/SoC-scoped Asahi boot ADR and recovery test |
| Legal/security | RebornOS examples include TrustAll; Asahi MIT and other distro GPL require source/attribution handling on reuse | No foreign code copies or unsigned repos in this pass | Licenses and patch provenance reviewed before import |

## Work selected

**M01-P03 (research):** accepted source registry, role instructions and Codex runbook. **M01-P04 (engineering):** accepted native Arch container test of packaged releng under ArchISO 92-1 ([CI run 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858)). Full `mkarchiso` execution is **M02-P01** and remains untested. Do not import themes, unsigned package sources, T2 firmware tools or Asahi installer internals in this pass.

## Repeatable reconnaissance

1. Confirm canonical upstream and branch; record full SHA, review date, license, inspected files and provenance, including mirrors.
2. Extract one observed design practice; document risk, Mac lane and ADOPT PATTERN / INVESTIGATE / BLOCKED / REJECT.
3. Propose a *Nemesis-owned* small change and a deterministic acceptance check. Do not copy code without licensing/security review.
4. Recheck HEAD before adopting changed source. Use [registry](UPSTREAM_REPOS.tsv), [Codex runbook](../../codex/UPSTREAM_RECON_RUNBOOK.md), and `bash scripts/recon-upstreams.sh`.

### Source links
- https://github.com/archlinux/archiso/tree/master/configs/releng
- https://github.com/archlinux/archiso/blob/master/docs/README.profile.rst
- https://github.com/endeavouros-team/EndeavourOS-ISO
- https://github.com/CachyOS/CachyOS-Live-ISO/blob/master/.github/workflows/build.yml
- https://gitlab.com/garuda-linux/tools/iso-profiles
- https://github.com/RebornOS-Team/rebornos-iso
- https://github.com/t2linux/archiso-t2
- https://github.com/t2linux/EndeavourOS-ISO-t2
- https://github.com/AsahiLinux/asahi-installer
