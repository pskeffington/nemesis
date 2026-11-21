# Operator Nemesis theme and object integration

**Status: review candidate.** This source change composes the canonical Nemesis palette, icons, and interactive Plasma 6 Theme Inspector into the separate Operator edition. No booted Plasma, actual icon rendering, or physical hardware acceptance is claimed.

## Source lineage and identity

The original design remains [draft theme PR #5](https://github.com/pskeffington/nemesis/pull/5). This integration deliberately starts from the current Operator mainline rather than merging the older theme branch's outdated ArchISO scripts. The brand masters in `brand/` are imported byte-for-byte from that branch. Violet `#883DFF`, cyan `#00A8FF`, and navy `#0B0E14` remain unchanged.

## Composition and applicability

In a trusted source staging/build context, explicitly opt in with:

```bash
NEMESIS_OPERATOR_BRAND=1 bash scripts/prepare-operator-profile.sh /absolute/new/operator-stage
```

The profile builder finishes its existing Operator overlay, wallpaper binary and network configuration, then calls `scripts/stage-operator-brand.sh`. With no flag (or `NEMESIS_OPERATOR_BRAND=0`), the previous Operator image layout remains unchanged. Other values fail closed.

The staging script installs:

- `/usr/share/color-schemes/Nemesis.colors` and `/usr/share/konsole/Nemesis.colorscheme`, selectable KDE/Konsole palettes.
- `/usr/share/plasma/desktoptheme/Nemesis/`, selectable Plasma Style that uses Breeze artwork fallback.
- `/usr/share/icons/hicolor/scalable/apps/nemesis.svg` and eight namespaced `nemesis-*.svg` icons.
- `/usr/share/plasma/plasmoids/org.nemesis.themecontrols/`, carrying the QtQuick three-component Inspector and byte-identical eight SVG objects.
- Original emblem, wordmark and SVG source wallpaper under `/usr/share/nemesis/brand/`.

The Inspector uses eight `QtQuick.Controls.Button` object tiles for mouse/keyboard selection, hover/pressed/focus/selected states, accessible object names, live detail text, cyan selection and strong-focus toggles, and reset. These are **visual interactions only**: selection never invokes a terminal, receiver, network, map tracking, drone or policy action.

Assets are **installed, not automatically selected**. KDE color scheme, Plasma Style and applet placement remain opt-in at the desktop UI; no settings, autostart or panel layout are overwritten. The real Operator `https://globe.airplanes.live/` background, offline fallback, live-only screenlock safeguards and SDDM session are unchanged. The standalone wallpaper SVG is not selected over the map.

## Validation and operational gates

`tests/test-operator-profile.sh` now composes both the default and explicitly branded Operator fixture and compares all eight deployed icons to canonical masters. It asserts exact KDE palette equality, preserved globe autostart/offline page and live-only screenlock policy, and that the default stage does not acquire theme objects. Existing source workflow `static.yml` exercises that fixture on PRs. The script preflights all asset sources/paths and rejects existing destinations, symlinked targets, non-Operator profiles and divergent icon copies.

Do not equate fixture checks with a booted GUI. Before marking complete, require: passing final-head GitHub source CI; a separately reviewed trusted-main Docker ISO built with the flag and actual SquashFS checks for the branded paths; explicit graphical/HiDPI/Kvantum focus, color and object interaction tests; then physical Mac testing under the existing GO gates. No privileged PR Docker builds or host machine actions.

## Revert / future rollout

Rollback is to omit `NEMESIS_OPERATOR_BRAND=1`; no rescue or lean Air profile is touched. The old theme PR remains a separate draft for standalone Garuda/preview tests. Do not merge that outdated branch wholesale into main. A later approved default theme selection requires a separate KDE runtime test and must not obscure the live aircraft background.
