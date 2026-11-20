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
