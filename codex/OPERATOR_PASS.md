# Nemesis Operator — Codex passes

**MODE:** GitHub source and approved disposable GitHub Docker only. No access to local Garuda/Mac, USB, firmware, partitions, or actual physical boot.

## OP-01 — Operator session and wallpaper source

**Owner:** `operator-desktop-engineer`. **Reviewer:** `security-release-reviewer`.

- Inspect [Operator spec](../spec/operator-edition.json), source manifests, upstream MIT Rust project at exact SHA `ee51045dc394f73d8151906fe9f397dd3cc94060`, and its locked dependencies.
- Validate KDE Wayland/SDDM session-only autologin, XDG wallpaper auto-start, online map `https://globe.airplanes.live/`, layer-shell check, click-through default and local offline fallback.
- Ensure `NetworkManager` is Operator-only, no competing network service symlinks, no SSH/modem auto-start, no default secrets, driver override, radio capture, or persistent internal-disk actions.
- Run Python, Bash/ShellCheck and native signed-ArchISO staging tests; retain exact GitHub checks.

**Gate:** source/fixture and native Arch CI green. Not a desktop runtime acceptance.

## OP-02 — Signed-Arch ISO packaging

**Owner:** `archiso-build-engineer`. **Reviewer:** QA/security.

1. In an ephemeral Docker builder, compile pinned first-party Rust source as a **non-root** user. Confirm license, source SHA, Cargo.lock SHA and produced binary SHA.
2. In separate **trusted-main privileged Docker** (only for `mkarchiso`), stage a distinct `nemesis-operator` image with official signed Arch desktop/field packages.
3. Verify ISO SHA-256, UEFI metadata, single fresh ISO, package manifest and actual SquashFS contents: Rust binary hash, KDE autostart, desktop session config, service safety, offline HTML, ADS-B/SDR/GNSS executables.
4. Record failures and source-specific evidence; no CI skip, package signature bypass, AUR installer or silent downgrade to an unfeatured image.

**Gate:** observed Docker binary and ISO/payload PASS. Source SHA acceptance never transfers to a new commit.

## OP-03 — Graphical session validation (separate future authorization)

Boot the exact ISO in a UEFI/KDE Wayland VM. Verify SDDM login once, wallpaper visible *below* panels/icons, map rendering, browser interaction versus click-through, compositor capability, start after reboot, and offline/online recovery. Check WebKit sandbox/site policy. A file-in-SquashFS test does not pass this gate.

## OP-04 — MacBook Air field proof (future separate GO)

Measure 4-GiB model memory/CPU/GPU, battery drain, thermal stability, keyboard/touchpad, Broadcom/USB networking, GNSS/SDR connectivity, safe recovery and macOS return. No automatic tuning or private logs committed.

## Theme pass

Once OP-03 passes, review source and UI assets from the separate [theme PR #5](https://github.com/pskeffington/nemesis/pull/5). Keep map as the focal background; no unreviewed provider logos/tiles. Test caption accessibility, readability, panel translucency and keyboard operation.

**Report:** pass ID, owner, commit, changed files, actual CI run and source hashes, PASS/FAIL/NOT RUN gates, blockers and next authorized pass.

## OP-P01 — MacBook lean package evidence and kit boundary

**Owner:** operator-desktop-engineer; **review:** archiso-build-engineer/security-release-reviewer. **Scope:** GitHub source and GitHub Actions Docker only.

1. Audit [source-linked package matrix](../docs/research/OPERATOR_PACKAGE_LIT_MATRIX.md) against official Arch packages and the current releng package list. Keep `firefox`, WebKitGTK and Plasma until the actual live map/user interaction path is accepted. Avoid KDE meta bundles and redundant runtime requests.
2. Maintain `spec/operator-kits.json` with exactly seven opt-in kits. `profiles/mac-intel-operator/packages.x86_64` is the **everyday core**, and `desktop.packages.x86_64` is the GUI. No optional kit may leak into either source manifest. Check upstream releng inheritance separately and apply only reviewed, safe Operator-only exclusions.
3. Run source Python, ShellCheck, synthetic and installed signed ArchISO staging. Validate each kit package name against signed Arch repositories; fail on missing/renamed packages. The kit CLI must list/show read-only, reject traversal/unsupported bundles and disallow live or unauthenticated installation.
4. Keep `mac-intel` and `macbook-air-field` images unchanged; retain map autoload, offline fallback, USB network path and no default remote/radio services.

**Acceptance:** observed source/native Arch checks and linked commit/run. No physical boot or installed-system test asserted.

## OP-P02 — Measured lean ISO acceptance

**Owner:** archiso-build-engineer. Fix the previously failing `xorriso -find … -print` check using supported `-lsd` for the ISO rootfs path; do not bypass SquashFS inspection. Build a fresh Operator ISO from pinned Rust source in approved GitHub Docker and prove checksum, EFI, actual wallpaper binary hash and kit manifests in SquashFS. Record exact image bytes, packages/ArchISO versions and compare to original ~2.3-GiB ISO *only when sources and upstream versions are comparable*. A build only satisfies assembly; graphical/physical operation remains untested.

## OP-P03 — Installed-system kit selection and GUI runtime

**Deferred:** the persistent installer must first configure real users, encrypted storage/recovery and authenticated root. Then confirm interactive `nemesis-kit install KIT` with rollback/recovery and user-selected use. Separately verify KDE Wayland map layering and 4-GiB battery/RAM/USB operation on approved hardware. No local machine execution in current phase.

## SIGINT-S01 — Comparable distribution deployments and potential kit expansion

**Owner:** operator-desktop-engineer. **Input:** [cross-distribution SIGINT package matrix](../docs/research/SIGINT_OS_PACKAGE_DEPLOYMENT_MATRIX.md), [machine inventory](../spec/sigint-distro-references.json), [existing Operator kits](../spec/operator-kits.json). **Status:** RESEARCH COMMITTED; no new default packages authorized.

- Contrast publisher lists from SigintOS 2.0, DragonOS Resolute R2.2, Skywave 5.10 and Pentoo profile design. Preserve distinctions between advertised software, package-managed files, `/usr/src` source-installed applications and actual ISO SBOMs.
- Evaluate optional **light signal GUI** (`sigdigger`, `inspectrum`), **basic data decoding** (`multimon-ng`), **aviation/airband** and **satellite** kit proposals using official signed Arch package availability and dependency sizes. Do not replace an approved application until measured workflows support the change.
- Do not import self-updating appimages, Linux distribution binary roots, AUR builds, active cellular base stations, interception frameworks or jammers as an Operator default. Services must be operator initiated and off by default.
- Record exact candidate/Arch package names, direct and transitive dependency closure, firmware/license requirements, background services, and USB/hardware constraints. Keep all build claims at their actual accepted source/CI gates.

## R29-03 — Offline field console source and CI (ACTIVE)

**Owner:** operator-desktop-engineer. **Review:** security-release-reviewer and build-qa-engineer. **Base:** the verified but still unmerged lean-toolkit branch `feat/operator-lean-toolkit-matrix`. Do not merge unrelated package changes implicitly.

1. Inspect [console contract](../spec/offline-field-console.json), [runbook](../docs/OPERATOR_FIELD_CONSOLE.md), the sourced 2029 capability matrix and the existing Operator staging script. Keep Airplanes.live wallpaper unchanged.
2. Validate `nemesis-field-note`: manual `add/list/status/export`, strict categories/text bounds, user ownership and private SQLite storage, explicit non-overwriting JSONL export, no network/dependency/server calls, and rejection of root and symlinks. Run real Python regression tests in GitHub foundation CI.
3. Validate `offline-field-map.html`: only explicitly selected local GeoJSON, no remote basemap, no location API, secure CSP with `connect-src 'none'`, bounded bytes/features/vertices, appropriate uncertainty wording and syntax checks where Node is available. Inspect menu launchers.
4. Verify source/script tests, synthetic profile staging and signed native ArchISO staging. The real Operator Docker/SquashFS gate must check the actual viewer, notebook executable and desktop entries before asserting that the binary image includes them. The ISO may still fail other preexisting CI gates: record the failure, do not bypass it.
5. If accepted, create a clean, separately reviewable changeset. Do not claim actual KDE rendering, usable offline street maps or physical Mac performance from source CI.

**Exit:** observed green source/fixtures + clear unresolved runtime/retention limits. Follow-up R29-04: opt-in Meshtastic and broadcast Remote ID hardware interface **research only**, no auto-scan or private-data relay. Full offline basemap/routing requires geographic data and license/quality gates before calling it navigation.

### R29-03 evidence receipt

- [Source `da112193`](https://github.com/pskeffington/nemesis/commit/da112193bd82dd4ec5184204337f300288723e8c): [foundation 44804592372](https://github.com/pskeffington/nemesis/actions/runs/44804592372) **PASS, 40 tests** including notebook SQLite and JS syntax; [static/installed ArchISO 44804592390](https://github.com/pskeffington/nemesis/actions/runs/44804592390) **PASS**.
- Source gates **ACCEPTED for source staging only**. Image SquashFS, KDE/Firefox rendering and actual MacBook Air field readiness are **NOT ACCEPTED**. Never copy this record to another source SHA without re-running checks. [Dependent PR #23](https://github.com/pskeffington/nemesis/pull/23) follows package [PR #21](https://github.com/pskeffington/nemesis/pull/21).
