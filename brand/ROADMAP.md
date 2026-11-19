# Nemesis branding milestone register

Statuses: NOT STARTED, READY, IN PROGRESS, BLOCKED, REVIEW, ACCEPTED, DEFERRED.

**Objective:** preserve the approved Nemesis brand while producing testable, reversible user-space appearances for Garuda Dr460nized / KDE Plasma 6, independently of Mac-first ISO readiness.

| ID | Checkpoint | Observed state |
|---|---|---|
| B01 | Emblem/wordmark source and palette reviewed at native sizes | REVIEW — source assets in Git |
| B02 | App/social avatars crop-tested | REVIEW — conversation ZIP; not imported to repo |
| B03 | Social banners mobile safe-area reviewed | REVIEW — conversation ZIP; not imported |
| B04 | Four cinematic 4K wallpaper masters | REVIEW — original ZIP; new vector signal dusk visually previewed at 1080p |
| B05 | Eight operator SVG glyphs and app icon | REVIEW — source files in Git |
| B06 | Garuda Dragonized theme staging and rollback | REVIEW — preview CLI implemented; five fixture tests passed locally, **no actual Garuda test** |
| B07 | Creative Theme Developer agent | REVIEW — instructions documented |
| B08 | Approved binary assets versioned in repo and hashed | NOT STARTED |
| B09 | Brand CI and release acceptance | REVIEW — brand CI and repository static CI passed; live Dragonized gate still pending |

## B06-P02: Dragonized preview deployment

**Owner:** Arch Theme Creative Developer. **Scope:** stage KDE colors, Konsole scheme, Breeze-fallback Plasma style, scalable app icon and vector wallpaper only in XDG user paths; optional color apply after storing previous scheme. **Exclusions:** system packages, Kvantum, GTK, full icon-theme replacement, panels, PLM/SDDM, boot graphics and ISO image.

**Files:** brand/scripts/dragonized.py, brand/scripts/dragonized.sh, brand/theme/plasma/Nemesis/, brand/wallpapers/signal-dusk.svg, tests/test_dragonized.py, brand/DRAGONIZED_TESTING.md.

**Executed local tests:** 2026-11-19 fixture suite (non-root fake XDG home), 5/5 PASS: read-only plan, idempotent install/uninstall, collision block, post-install modification guard, apply/restore through a stubbed Plasma tool. Bash syntax and Python compile passed locally. Vector wallpaper rendered for preview at 1920×1080 and was visually inspected. Real KDE/Garuda test remains pending.

**Acceptance gate:** actual Dr460nized Plasma session can apply/revert colors without harming its global theme or panels; inspect wallpaper output from rsvg-convert at 3840×2160 and record screenshot evidence. Do not advance to ACCEPTED before physical validation.

**Rollback:** bash brand/scripts/dragonized.sh restore then bash brand/scripts/dragonized.sh uninstall; manually undo any independently selected desktop style, wallpaper or Konsole profile.

**Next pass B06-P03:** run on an actual Dragonized desktop, compare Dr460nized/Kvantum effects, verify focus/contrast and record versioned acceptance evidence. Parallel B04-P03: replace schematic wallpaper with polished cinematic masters (do not overwrite original approved board). Next B08-P02: import reviewed binaries with hashes.

The distro ISO and Intel Mac hardware gates M01–M05 are unchanged.

## 2026-11-19 verification update

- GitHub commit `e57a887d477e0170d718045f275363f35c243238` committed the stage/apply/restore scripts, source wallpapers, Plasma style, tests, and runbook.
- Brand preview checks: **PASS** — https://github.com/pskeffington/nemesis/actions/runs/44607050004
- Root static checks: **PASS** — https://github.com/pskeffington/nemesis/actions/runs/44607050005
- Draft integration PR: https://github.com/pskeffington/nemesis/pull/5 — no merge until real workstation acceptance.
- B06 physical acceptance remains REVIEW, never ACCEPTED based only on mock XDG tests.

## B06-P04: Operability hardening and diagnostics

Owner: Arch Theme Creative Developer. The live Dragonized test remains B06-P03 (OPEN, issue #6), so B06-P04 is an independent source and fixture pass, not physical acceptance.

New operations: doctor, apply-style and restore-style. The color and Plasma Style backups are separate; a partially failed KDE apply retains recovery information when it has changed the active appearance. Staging/uninstall guard against unexpected symlinks, tampered state path/hash entries, modified files, and active wallpaper/Plasma Style/Konsole selections. Mutations use a per-user exclusive file lock.

Acceptance evidence: 16 non-root fixture tests on temporary XDG folders, plus Python compilation. GitHub CI must pass on this commit before source-gate acceptance. Physical test still requires actual Garuda Dr460nized Plasma, Kvantum, panels, wallpaper and recovery verification. See brand/OPERABILITY.md.

Rollback: restore-style, restore, uninstall, with manually chosen wallpaper and Konsole profile selections reverted in System Settings. Never force removal of an active UI resource.

## B06-P04 acceptance evidence (2026-11-19)

**ACCEPTED for source + fixture gates only.** The committed CLI and 16 non-root temporary-XDG tests passed the dedicated [brand CI workflow](https://github.com/pskeffington/nemesis/actions/runs/44609458263); the [root static checks](https://github.com/pskeffington/nemesis/actions/runs/44609457998) also passed for commit `38a4e14609e1782f5a6c501d2482aafd1c57746d`.

The physical Dr460nized test is **NOT ACCEPTED**; [B06-P03 issue #6](https://github.com/pskeffington/nemesis/issues/6) remains open for real KDE color/style, Konsole, wallpaper, Kvantum relogin and restore evidence. [Draft PR #5](https://github.com/pskeffington/nemesis/pull/5) stays unmerged.

**Next executable pass:** obtain the noncritical Garuda machine evidence using `brand/OPERABILITY.md`, fix any observed compatibility defects, and retain screenshots/commands in the physical acceptance issue.

## B10 / F06-ISO-01 — Stage Nemesis assets into an opt-in Intel ArchISO variant

**Status: REVIEW** pending unprivileged Arch Docker source-staging CI. The build variant keeps the default mac-intel rescue image unmodified while installing KDE colors/Plasma Style/Konsole wallpaper and optional package names to its own staging tree. Source: `scripts/prepare-theme-profile.sh`, `profiles/mac-intel-theme-preview/`, `tests/test-theme-iso-staging.sh`; details [theme integration](../docs/THEME_ISO_PREVIEW.md). Trusted-main manual Docker mkarchiso, GUI login and real Mac boot remain separate unaccepted gates. Explicit fallback is baseline `mac-intel`; do not merge the existing draft brand PR without review.

## B11-P01 — Eight Nemesis objects with real interactive states

**Purpose:** Convert the existing eight SVG source icons into a reusable Qt Quick Controls object system rather than merely displaying static mockups.

**Owner:** Arch Theme Creative Developer; peer review by build-qa-engineer. **Artifacts:** `brand/plasmoid/org.nemesis.themecontrols/`, canonical `brand/icons/`, `tests/qml/tst_theme_board.qml`, `tests/test_theme_interactivity.py`, `brand/INTERACTIVE_OBJECTS.md`.

**Functional scope:** eight objects, mouse/touch and Space/Return activation through Qt Quick Controls, visible selected/hover/pressed/focus states, cyan/purple selection and strong focus adjustments, text description updates and reset. Actual remote/hardware/backend operations deliberately excluded.

**Docker gates:** Qt6 QML syntax parsing, headless Qt Quick Test interaction checks, XML/metadata/color contrast source checks, and packaged ArchISO asset checks. **Status:** IN PROGRESS until CI evidence is observed. UI on an actual Dragonized Plasma session, Kvantum integration, and real ISO boot remain REVIEW/NOT TESTED under issues #6 and #14. Rollback: remove the opt-in widget after removing it from Plasma panels or revert B11 source; baseline mac-intel rescue stays unchanged.
