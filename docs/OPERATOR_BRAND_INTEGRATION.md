# Operator Nemesis theme and object integration

**Status: review candidate.** This source change composes the canonical Nemesis palette, icons, and interactive Plasma 6 Theme Inspector into the separate Operator edition. No booted Plasma, actual icon rendering, or physical hardware acceptance is claimed.

## Source lineage and identity

The original design remains [draft theme PR #5](https://github.com/pskeffington/nemesis/pull/5). This integration deliberately starts from the current Operator mainline rather than merging the older theme branch's outdated ArchISO scripts. The eight canonical SVG objects, palette and identity master files are imported from that branch; the Plasma Style metadata gains its Plasma 6 package-structure declaration, and `brand/operator-defaults/` adds live-session configuration. Violet `#883DFF`, cyan `#00A8FF`, and navy `#0B0E14` remain unchanged.

## Composition and applicability

In a trusted source staging/build context, explicitly opt in with:

```bash
NEMESIS_OPERATOR_BRAND=1 bash scripts/prepare-operator-profile.sh /absolute/new/operator-stage
```

The profile builder finishes its existing Operator overlay, wallpaper binary and network configuration, then calls `scripts/stage-operator-brand.sh`. With no flag (or `NEMESIS_OPERATOR_BRAND=0`), the previous Operator image layout remains unchanged. Other values fail closed.

The staging script installs both the reusable assets and **reversible, non-immutable defaults** inside the opted-in disposable Operator ISO:

- `/usr/share/color-schemes/Nemesis.colors` and `/usr/share/konsole/Nemesis.colorscheme`, selectable KDE/Konsole palettes.
- `/usr/share/plasma/desktoptheme/Nemesis/`, Plasma 6 Style with a Breeze artwork fallback and declared `KPackageStructure: Plasma/Theme`.
- `/etc/xdg/kdeglobals` (the full canonical Nemesis KDE color group values), `/etc/xdg/plasmarc` (`[Theme] name=Nemesis`) and `/etc/xdg/konsolerc` (`DefaultProfile=Nemesis.profile`), plus `/usr/share/konsole/Nemesis.profile`. These seed default visual behavior for a fresh live session without kiosk locks.
- `/usr/share/icons/hicolor/scalable/apps/nemesis.svg` and eight namespaced `nemesis-*.svg` icons. The *staged copies only* of the existing aircraft-map and readiness launchers bind to `nemesis-location` and `nemesis-shield`, respectively; their commands remain byte-for-byte unchanged.
- `/usr/share/plasma/plasmoids/org.nemesis.themecontrols/`, carrying the QtQuick three-component Inspector and byte-identical eight SVG objects.
- Original emblem, wordmark and SVG source wallpaper under `/usr/share/nemesis/brand/`.

The Inspector uses eight `QtQuick.Controls.Button` object tiles for mouse/keyboard selection, hover/pressed/focus/selected states, accessible object names, live detail text, cyan selection and strong-focus toggles, and reset. These are **visual interactions only**: selection never invokes a terminal, receiver, network, map tracking, drone or policy action.

**Runtime selection semantics:** the build flag opts the *live image* into Nemesis KDE, Plasma Style and Konsole defaults, and binds the two named Operator menu objects to their icons. A user's own KDE settings may override these non-immutable system defaults; this feature does not promise an override of a configured persistent home. The standalone Inspector is available for manual placement (Add Widgets) but is never silently pinned to a panel or started in the background. The live globe `https://globe.airplanes.live/`, offline fallback, live-only screenlock safeguards and SDDM session remain untouched; the standalone SVG wallpaper is never selected over the aircraft map. No files on the host workstation are modified.

## Validation and operational gates

`tests/test-operator-profile.sh` now composes both the default and explicitly branded Operator fixture and compares all eight deployed icons to canonical masters. It asserts exact KDE palette equality, preserved globe autostart/offline page and live-only screenlock policy, and that the default stage does not acquire theme objects. The `static.yml` workflow exercises that fixture, while `operator-brand-ui.yml` performs *actual Qt 6 offscreen* QML interactions and verifies all eight SVG images decode to `Image.Ready`. Signed Arch releng staging checks the same live defaults against an installed ArchISO profile; the future built-SquashFS check also reads the actual staged configuration, launcher references and canonical icon bytes. The staging script preflights sources and paths and rejects existing destinations, symlinked targets, non-Operator profiles and divergent icon copies. The previously unsupported `xorriso -find ... -print` verifier is replaced with `-lsd` for the ISO rootfs member, matching the separate fix developed in PR #21. None of these checks prove a graphical Plasma desktop or the output of a physical monitor.

Do not equate fixture checks with a booted GUI. Before marking complete, require: passing final-head GitHub source CI; a separately reviewed trusted-main Docker ISO built with the flag and actual SquashFS checks for the branded paths; explicit graphical/HiDPI/Kvantum focus, color and object interaction tests; then physical Mac testing under the existing GO gates. No privileged PR Docker builds or host machine actions.

## Revert / future rollout

Rollback is to omit `NEMESIS_OPERATOR_BRAND=1`; no rescue or lean Air profile is touched. The old theme PR remains a separate draft for standalone Garuda/preview tests. Do not merge that outdated branch wholesale into main. Do not make this optional theme the **unbranded Operator default** or embed it in rescue/Air profiles before graphical/Kvantum acceptance. Plasma/KConfig system defaults are documented in the [KDE Kiosk configuration hierarchy](https://develop.kde.org/docs/administration/kiosk/introduction/), with Plasma Style fallback behavior in the [theme reference](https://develop.kde.org/docs/plasma/theme/theme-details/).
