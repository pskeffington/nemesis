# M3-GUI-V01 — Codex graphical validation handoff

**Owner:** Codex local Mac implementation agent; independent reviewers: desktop QA and security.
**Current status:** PREPARED, **NOT RUN on Apple M3**.
**Source:** `pskeffington/nemesis`, feature branch `feat/m3-arm64-vm-optimization`, stacked on `feat/operator-brand-object-integration` ([PR #25](https://github.com/pskeffington/nemesis/pull/25) → [PR #24](https://github.com/pskeffington/nemesis/pull/24)).
**Authority:** Root [AGENTS.md](../AGENTS.md) and [execution handoff](HANDOFF_CONTRACT.md). Existing `REPO_FOUNDATION` **NO-GO applies to Mac execution** until the user explicitly authorizes local M3/UTM work and grants access. A question about whether Codex *can* perform the work is not that authorization.

## What Codex can and cannot establish

- **Codex Cloud / GitHub CI can do now:** source checks; portable ARM64 tests; offscreen Qt 6 SVG and keyboard/mouse tests; produce test scaffolds, deterministic reports, review diffs and evidence contracts.
- **Codex on the user's M3 with local permissions can do *after GO*:** inspect the designated disposable UTM VM, interact with the Fedora KDE ARM64 guest by supported Computer Use or an explicitly approved guest test bridge, take scoped screenshots, run read-only guest commands, compare performance, and repair preview/theme issues in a branch.
- **Not equivalent:** GitHub ARM64 runners do not have Apple M3 silicon; Qt offscreen is not a booted Plasma session; a UTM guest uses virtual hardware and does not test native Asahi GPU, battery, firmware or display.
- **Unable to proceed automatically:** if UTM, guest GUI access, Screen Recording/Accessibility or permission to use them is absent, stop at `BLOCKED_NEEDS_USER`. Never silently install a hypervisor, change macOS privacy settings, virtualize an x86_64 Intel ISO as an M3 baseline, or spoof evidence.

## Goal and scope

Verify visually that Nemesis design components work in an **aarch64 Fedora KDE Plasma guest on a user's actual M3 host**, with measurable before/after overhead. Do not attempt to boot the existing Intel ArchISO on M3. Use the architecture and sizing contract in [spec/m3-arm64-vm.json](../spec/m3-arm64-vm.json) and the baseline procedure in [docs/M3_OPTIMIZATION.md](../docs/M3_OPTIMIZATION.md).

The target is a *temporary guest test*, not conversion of `mac-asahi` to a built/supported edition. Maintain the independent Intel rescue, Air and Operator source. Do not modify native macOS boot, APFS partitions, recovery, firmware, SIP, paired devices, macOS power/security settings or external peripherals.

## Codex execution modes and authorization gates

### Phase A — repository-only, authorized now

1. Read root `AGENTS.md`, both PR descriptions, `codex/M3_GRAPHICAL_VALIDATION_PASS.md`, `docs/M3_OPTIMIZATION.md`, `spec/m3-arm64-vm.json`, `spec/m3-gui-acceptance.json`, and the current test workflows.
2. Confirm exact base/head SHA and that local worktree is clean; create a feature/fix branch (never force-push and do not merge PR #24 or #25).
3. Review QML inspector tests `tests/qml/tst_theme_board.qml` and native ARM64 [workflow](../.github/workflows/m3-arm64.yml); extend only for measurable missing assertions.
4. Prepare a reproducible **read-only** guest observation procedure, screenshot checklist and evidence report. Do not claim M3 VM observations from GitHub tests.
5. Run or inspect GitHub CI at exact final SHA. Preserve test names, failures, timestamps, source provenance. Keep results sanitized and limited to the guest.

### Phase B — actual M3/UTM GUI, **only after explicit GO from user**

**Preflight:** confirm Codex is running locally on the designated M3 Mac, *not* in a remote cloud container. Obtain approval to use UTM and operate its existing test VM. If no disposable ARM64 VM exists, propose its configuration and ask approval before creating/installing one. The first test must not create host storage outside the specifically approved VM bundle. Check host RAM headroom; target the nearest safe preset, default 1920×1200, no host shared folders or USB passthrough; use an isolated snapshot/backup before guest changes.

1. Confirm UTM is virtualizing **aarch64 Fedora KDE**, not emulating x86_64. Record generic host class `Apple M3` (no serial/model UUID), guest OS/version, `uname -m`, desktop/session, Qt/KDE versions, VM CPU/RAM and graphics driver class. Run `python3 scripts/m3-vm-audit.py --require-arm64` in the guest as a normal user.
2. Take an initial **guest-only** screenshot of KDE desktop, panels, Konsole and launcher list. Avoid capturing host desktop, credentials, personal files, browser accounts or surrounding apps. Screenshots require user-authorized recording or guest-native capture. If no screenshot path is available, classify visual tests `BLOCKED`, not `PASS`.
3. Record stock KDE idle baseline **after five minutes** and three supervised cold-boot-to-desktop observations. Use measured units/time and reproducible method. Do not infer FPS, energy efficiency or GPU acceleration from `uname` or Qt alone. If possible, record guest `MemAvailable`, shell/process CPU, memory pressure and compositor mode.
4. Prepare Nemesis per-user theme via `brand/scripts/dragonized.sh doctor`, `plan`, `install`. Reconfirm recoverable prior `ColorScheme` / `Plasma Style` before `apply` or `apply-style`. Do not use sudo for this theme installer; no global KDE settings, panel autostart or host appearance.
5. Open the Inspector manually via **Add Widgets** (or `plasmawindowed` if supported). Visually inspect all eight SVG objects at **100% and 200% scaling**, selected states, mouse hover, keyboard Tab/Space/Enter, focus ring, strong focus, cyan accent and Reset. Verify actual icon pixels/sizing, no clipped text, no blank or missing objects. Collect guest-only screenshots before/after, label them with dimensions, and record every FAIL.
6. Verify KDE menu/application icon selection, Konsole colors and Plasma panel contrasts. For portability across Fedora and Arch, do not assume that generic Fedora launcher files already contain the Intel Operator-specific `nemesis-` application icon names; note any gap rather than claiming end-to-end Operator desktop packaging.
7. After the baseline, optionally launch `https://globe.airplanes.live/` in the guest's **ordinary browser** with consent. Measure CPU and memory delta separately. The current Intel-specific Rust live-wallpaper is **not** a runnable aarch64 binary, and a browser window is **not** proof of live wallpaper layering. Do not enable radio capture or geolocation.
8. Remove the inspector from any panel, restore the original theme via `restore-style`, `restore`, `uninstall`, and inspect the desktop again. If restore refuses because resources are in use or user files changed, stop, preserve the state, request assistance—never delete foreign files.

### Phase C — acceptance and next development pass

A `PASS` requires direct observation, screenshot/evidence reference, tested source SHA and the exact VM/Qt/KDE context. Fill an evidence report based on the IDs in `spec/m3-gui-acceptance.json`, with `PASS`, `FAIL`, `BLOCKED`, or `NOT_RUN`. Keep raw screenshots/host diagnostics **outside the Git repository** until sanitized and approved; use references in a local evidence manifest or private attachment. Do not commit host serial numbers, screenshots containing identities, MAC addresses, SSIDs, precise location, credentials or live telemetry.

Codex should produce:
- one concise defect list with severity, observed vs expected, screenshot or log reference;
- measured stock-vs-Nemesis data with sample count and units, and regressions explicitly noted;
- minimal fixes in this branch plus repeatable GitHub CI (separate from VM evidence);
- final `M3-GUI-V01` report showing **GUI ACCEPTED / GUI BLOCKED / GUI FAILED**, while `M3-N01 native Asahi hardware` remains **NOT TESTED**.

## Stop/rollback rules

Stop on unknown environment, install/partition prompts, VM disk selection outside the approved bundle, security-privacy permission prompts, screen recording of non-guest surfaces, missing rollback metadata, repeated GUI crashes or unexpected hardware I/O. Request user approval before continuing. Never use GUI automation or shell execution to bypass host security controls. Restore the disposable VM snapshot only if separately approved and it does not discard unrelated user work.

## Codex kickoff prompt (paste into a **local M3 Codex** session)

> Continue `pskeffington/nemesis` PR #25, starting with `AGENTS.md`, `codex/M3_GRAPHICAL_VALIDATION_PASS.md`, `spec/m3-gui-acceptance.json` and `docs/M3_OPTIMIZATION.md`. First complete **Phase A repository-only readiness** and show me the exact UTM/M3 permission plan. Do **not** start local VM or host actions before I explicitly say GO. After I grant GO and local Computer Use is enabled, execute Phase B in the designated Fedora KDE aarch64 UTM VM, capture scoped guest screenshots, measure baseline vs Nemesis, log defects, restore the theme and produce the Phase C evidence report. No native Asahi installation, disk changes, USB capture or false GPU/boot claims.

**Gate status as of authoring:** M3 feature branch ARM64 source/QML CI previously passed at [run 44889107637](https://github.com/pskeffington/nemesis/actions/runs/44889107637). No UTM/Apple M3 GUI session has been executed by this handoff.
