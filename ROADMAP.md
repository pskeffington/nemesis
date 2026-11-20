# Nemesis — program roadmap (GitHub foundation phase)

**Effective 2026-11-19.** **Active phase: repository source, research, architecture and handoff preparation.** The current user directive is **no user Linux/Mac machine execution**. User explicitly authorized **GitHub-hosted Docker ISO build validation only** (F02-V01), without QEMU, USB or deployment. The [foundation priority plan](docs/FOUNDATION_PRIORITY_PLAN.md) governs F00–F06. Historical M-series milestones remain below as *future* execution gates.

## Current repository-only work queue

| Priority | Pass | Purpose | Owner agent | Gate | State |
| --- | --- | --- | --- | --- | --- |
| P0 | F00 | Baseline source/CI and upstream distro recon | distro-architect | versioned research and prior source CI | ACCEPTED |
| P0 | F01 | Edition and platform contract | distro-architect | `spec/editions.json` + GitHub source test | ACCEPTED — [CI 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155) |
| P0 | F02 | Package composition, manifest dependencies/conflicts | archiso-build-engineer | source-owned policy + deterministic checks | **ACCEPTED (repo source design)** — [CI 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336) |
| P0 | F02-V01 | Docker CI compile of baseline Intel ISO, checksum and UEFI image metadata | archiso-build-engineer | real mkarchiso 0, SHA-256 checked and UEFI metadata present | **ACCEPTED (assembly only)** — [CI 44610122687](https://github.com/pskeffington/nemesis/actions/runs/44610122687); not booted |
| P0 | F03-A01 | MacBook Air field source and offline/power diagnostics | macbook-air-field-engineer | six models, optional manifest, fixture CI | ACCEPTED (source) — [CI 44612120052](https://github.com/pskeffington/nemesis/actions/runs/44612120052) |
| P0 | F03-A02 | Independent MacBook Air field ISO | archiso-build-engineer | staged profile fixture; Docker mkarchiso, SHA and EFI checks | IN PROGRESS — [first Docker ISO PASS](https://github.com/pskeffington/nemesis/actions/runs/44612684836); [hardened Docker](https://github.com/pskeffington/nemesis/actions/runs/44614544328) pending, [#15](https://github.com/pskeffington/nemesis/issues/15) |
| P0 | OP-01 | KDE Operator profile with Airplanes.live startup and preloaded tools | operator-desktop-engineer | pinned first-party wallpaper, signed package manifests, autostart and offline fallback | SOURCE COMMITTED — [PR #18](https://github.com/pskeffington/nemesis/pull/18), CI review |
| P0 | OP-02 | Docker build the separate graphical Operator ISO | archiso-build-engineer | pinned Rust binary/hash, mkarchiso, ISO SHA and SquashFS tools/startup inspection | NOT YET ACCEPTED — [workflow](.github/workflows/docker-operator.yml) |
| P0 | F03 | Mac device/firmware support and compatibility evidence schema | intel-mac-compatibility | source-linked feature-level contract, no false PASS claims | **READY — ACTIVE NEXT**, [#9](https://github.com/pskeffington/nemesis/issues/9) |
| P0 | F04 | Build provenance, release security, recovery policy | security-release-reviewer | signed-source/rollback/artifact design review | NOT STARTED |
| P1 | F05 | Complete and approve Codex handoff packet | build-qa-engineer | all P0 gates + explicit user GO | NOT STARTED / NO-GO |
| P2 | F06 | Optional Nemesis icon/wallpaper/KDE theme | visual development branch | provenance, contrast and reversible UI review | PARALLEL; PR #5 open |

Source checks and the specifically authorized **GitHub-hosted privileged Docker** image build may run in GitHub Actions. No local Linux/Arch/Garuda host deployment, QEMU, USB, firmware, partition or physical hardware work is authorized. Docker compilation does not satisfy virtual or physical boot gates. A draft/commit is not evidence of successful runtime behavior.

## Repo-phase milestone dependency

```text
F00 -> F01 -> F02
             \-> F03
F02 + F03 -> F04 -> F05 -> [explicit GO] -> M02
F06 is independent optional visual design; it does not gate M02.
M02 ISO -> M03 virtual UEFI -> M04 physical Intel Mac.
```

## Planned execution milestones — parked

| Milestone | Outcome | Required prior gate | Current status |
| --- | --- | --- | --- |
| M00 | Initial repo authority and source inspected | none | ACCEPTED |
| M01 | Intel ArchISO scaffold, source fixtures and real releng staging CI | M00 | ACCEPTED (source/profile only) |
| M02-P01 | Local/handoff x86_64 non-T2 Intel ISO build | F05 accepted **plus user GO for local execution** | **DEFERRED**, issue [#2](https://github.com/pskeffington/nemesis/issues/2) remains open |
| M03-P01 | ISO boots to live shell in x86_64 UEFI VM | M02 evidence | DEFERRED, [#3](https://github.com/pskeffington/nemesis/issues/3) |
| M04-P01 | External boot and feature-level acceptance on real non-T2 Intel Mac | M03 + test hardware and recovery | DEFERRED, [#4](https://github.com/pskeffington/nemesis/issues/4) |
| M05 | Safe accessible KDE/installer with macOS recovery plan | M04 | DEFERRED |
| M06 | T2-specific feasibility, firmware trust, physical acceptance | separate T2 policy/hardware | RESEARCH ONLY |
| M07 | Apple Silicon/Asahi ARM64 platform | distinct boot/installer safety | RESEARCH ONLY |
| M08 | Optional operator/RF editions | validated core and platform | DEFERRED |

## Accepted source contract — F02

- **Goal:** define a verifiable package-layer dependency, conflict and trust model before Codex implements any new image or optional edition.
- **Owner:** archiso-build-engineer; security-release-reviewer checks external source/trust policy.
- **Inputs:** `spec/editions.json`, `profiles/mac-intel/packages.x86_64`, `docs/research/UPSTREAM_DISTRO_RECON.md`.
- **Output:** machine-readable package layer policy, source-only validator and a source-backed decision on merge precedence and exemptions.
- **Acceptance:** GitHub tests pass; manifest references exist or are clearly marked planned; no unsigned third-party repo, silent T2/ARM cross-inclusion or unauthorized default desktop/operator packages.
- **Failure/rollback:** keep previous accepted edition contract; revert the failing spec/test commit; no machine cleanup.
- **Status:** ACCEPTED as a **repo-only package-layer contract**. [Commit 9105adc](https://github.com/pskeffington/nemesis/commit/9105adc5d62d6d3fac623822a3d5579166e2bda5) and [GitHub Actions 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336) passed **11 Python source tests**; [static source workflow 44608516293](https://github.com/pskeffington/nemesis/actions/runs/44608516293) also passed. JSON is not wired to the builder; no live package resolver or image was run.

## Active next pass — F03
- **Owner:** intel-mac-compatibility with T2/Asahi and security reviewers.
- **Scope:** MacBookAir7,2 and 6,x first; optional field package layer and read-only battery/thermal/wireless readiness tool, with source-only contract and driver/firmware license policy. No physical evidence or auto power tuning.
- **Acceptance:** no invented PASS hardware, no T2/ARM crossover, no firmware/host changes, passing GitHub source CI.
- **Issue:** [F03 #9](https://github.com/pskeffington/nemesis/issues/9).

## Prior evidence and limits

- Source/fixture static CI and real installed ArchISO releng profile-staging CI passed on signed ArchISO **92-1**, [GitHub Actions 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858). It preserved EFI/GRUB/syslinux folders, pacman.conf, manifest uniqueness and diagnostic overlay.
- Comparative source review covered ArchISO, EndeavourOS, CachyOS, RebornOS, Garuda, t2linux and Asahi; see [source matrix](docs/research/UPSTREAM_DISTRO_RECON.md). A source-head SHA is not a tested runtime.
- New repo-only edition contract source test passed [run 44608135155](https://github.com/pskeffington/nemesis/actions/runs/44608135155).
- **F02 package-layer source policy** [commit 9105adc](https://github.com/pskeffington/nemesis/commit/9105adc5d62d6d3fac623822a3d5579166e2bda5) accepted from [11 GitHub contract tests](https://github.com/pskeffington/nemesis/actions/runs/44608516336), plus [static CI](https://github.com/pskeffington/nemesis/actions/runs/44608516293). No runtime package integration.
- **Docker ISO pass:** [run 44610122687](https://github.com/pskeffington/nemesis/actions/runs/44610122687) successfully built a ~1.3-GB Intel ISO, verified its SHA-256 twice and detected UEFI El Torito metadata; source was `cc93fd9f`. The ISO was not uploaded as a release, nor booted in QEMU or on a Mac.
- **Air field source pass:** [commit c3cd977](https://github.com/pskeffington/nemesis/commit/c3cd977535a5d41ef9e9befe9bd4d0c0ede54240) added optional field profile source and tests; [foundation CI 44612120052](https://github.com/pskeffington/nemesis/actions/runs/44612120052) and [static CI 44612120050](https://github.com/pskeffington/nemesis/actions/runs/44612120050) passed. The field layer remains **unselected** in the default image.
- **Independent field builder:** [source commit e1f12a4](https://github.com/pskeffington/nemesis/commit/e1f12a48d89ac51b14f3cb1ab2fca8f1e15ef995) added separate Air staging/build scripts and a dedicated Docker workflow. Source/fixture CI passed. The first Air Docker ISO [run 44612684836](https://github.com/pskeffington/nemesis/actions/runs/44612684836) also passed (~1.3 GB, checksum OK, UEFI metadata); hardened [commit 0257b09](https://github.com/pskeffington/nemesis/commit/0257b09bc03cc55b0931b411372af126ae8efbe5) requires its own [Docker/payload gate 44614544328](https://github.com/pskeffington/nemesis/actions/runs/44614544328). No UEFI VM/Mac boot, installation, T2/ARM release or on-device theme acceptance has occurred.
- Separate visual work exists in [PR #5](https://github.com/pskeffington/nemesis/pull/5); its physical Garuda proof [issue #6](https://github.com/pskeffington/nemesis/issues/6) remains future work.

## Risks and authority

- **R-F01:** “build next” in older runbooks conflicts with current repository-only phase. This roadmap and [AGENTS.md](AGENTS.md) take precedence.
- **R-F02:** source CI cannot prove packages build or boot; keep source, built image, UEFI and physical evidence separate.
- **R-F03:** Broadcom, audio, camera, EFI, T2 and ARM coverage differs by model/SoC. Unknown remains unverified.
- **R-F04:** no unsigned/untrusted package feeds, proprietary Apple firmware bundling or internal disk write automation.
- **R-F05:** design/artwork is separate from core boot and security; no forced merge of active brand PR.

**Future transition:** only after F05 acceptance and explicit user instruction. The inactive [Linux execution prompt](codex/LINUX_EXECUTION_PROMPT.md) and [build runbook](codex/BUILD_RUNBOOK.md) remain reference material until then.

## Operator edition — live aircraft globe (2026-11-20)

The user selected the **Operator edition** for all integrated desktop tools and a live aircraft map as the central wallpaper. [Operator source specification](docs/OPERATOR_EDITION.md) and [PR #18](https://github.com/pskeffington/nemesis/pull/18) provide an independent `mac-intel-operator` ISO path. It inherits conservative Air hardware configuration, adds Plasma Wayland, a live-only nonprivileged operator login, signed SDR/ADS-B/GNSS/network packages, and pins the MIT Rust [linux_live_wallpaper](https://github.com/pskeffington/linux_live_wallpaper) source to `ee51045dc394f73d8151906fe9f397dd3cc94060`.

- **OP-01:** KDE XDG session autostart, default `https://globe.airplanes.live/`, local non-data offline fallback and reconnect, no competing iwd/networkd with the Operator NetworkManager, disabled SSH/modem auto-start, no embedded credentials. **SOURCE COMMITTED, validation review underway.**
- **OP-02:** compile pinned app without root in disposable Docker; then distinct privileged Docker `mkarchiso` with SHA-256/UEFI/SquashFS/package verification. **NOT YET ACCEPTED**.
- **OP-03:** actual UEFI/Plasma Wayland graphical session, layer placement behind KDE panels and icons, one startup per reboot, WebKit globe rendering, browser interaction, network recovery. **NOT RUN — explicit later approval.**
- **OP-04:** physical MacBookAir7,2/6,x battery, memory, Wi-Fi/USB, SDR and return to macOS tests. **NOT RUN — explicit later approval.**
- **Theme:** Nemesis panel/icon work from PR #5 stays independent until visual KDE rendering and licensing are accepted; the map remains the primary visual surface.

No live-mapped aircraft positions are available offline: the original standby HTML is only an offline indicator. Operator tools are installed but never automatically scan, capture, transmit or establish remote access.
