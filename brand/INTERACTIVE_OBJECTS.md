# B11 — Nemesis icon-object interaction contract

**Artifact:** `brand/plasmoid/org.nemesis.themecontrols/` — one self-contained Plasma 6 applet, explicitly opt-in. The canonical source icons remain in `brand/icons/`; eight mirrored applet SVGs and hicolor icons are verified byte-identical. This is an interaction/design sandbox, **not a live signal, GIS, network, defense, satellite, audio or drone operator**.

## Objects and behavior

| Object / source SVG | Selection label | Visible behavior |
|---|---|---|
| terminal.svg | Console | Updates detail text; no command execution |
| radio.svg | Signals | Updates detail text; no receiver access |
| database.svg | Data | Updates detail text; no database reads |
| location.svg | GIS | Updates detail text; no geolocation |
| drone.svg | Platform | Updates detail text; no vehicle control |
| satellite.svg | Satcom | Updates detail text; no satellite link |
| headphones.svg | Audio | Updates detail text; no microphone use |
| shield.svg | Defense | Updates detail text; no firewall/policy changes |

A `QtQuick.Controls.Button` handles pointer click, touch and keyboard activation. Each tile has explicit selected/hover/pressed/focus/disabled visual treatment, a visible text label and `Accessible.name`/description. The board uses one selected object at a time. Separate CheckBoxes change the actual highlight accent (purple ↔ cyan) and keyboard-focus stroke thickness; **Reset preview** restores the initial state. Unknown object keys are ignored; no external settings or state files are changed.

## Installed paths

- User preview: `~/.local/share/plasma/plasmoids/org.nemesis.themecontrols/`, staged through `brand/scripts/dragonized.sh install`; never added to a panel automatically.
- Separate ISO preview: `/usr/share/plasma/plasmoids/org.nemesis.themecontrols/` plus eight namespaced `/usr/share/icons/hicolor/scalable/apps/nemesis-*.svg`.
- `mac-intel` rescue stage: no Plasma widget or extra icon payload.

KDE Plasma 6 requires a root `PlasmoidItem`, widget `metadata.json` with `KPackageStructure: Plasma/Applet`, `X-Plasma-API-Minimum-Version: 6.0`, and `contents/ui/main.qml`. The independent `ModeBoard.qml` and `IconTile.qml` depend only on QtQuick/QtQuick.Controls, enabling headless tests without starting Plasma.

## Automated tests

**Unprivileged GitHub Arch Docker:** installs signed Arch `qt6-declarative`, `qt6-svg`, `archiso` and `librsvg`; runs `qmlformat` for QML syntax, `qmltestrunner` headless with the software renderer, Python icon/metadata/accessibility/contrast source contracts, and ArchISO staging checks. Tests check 8 objects, clicked and keyboard-selected state, detail text, accent/focus toggles, reset, unknown key handling and source file parity.

**Not proven by Docker:** Plasma shell launch on Dragonized; actual icon rendering in Kvantum; panel-size/HiDPI legibility; ISO boot; macOS recovery; any live data/SDR control. These remain separate acceptance issues.

## Manual future Plasma gate (no automatic deployment)

In a noncritical Plasma 6 user session, preview via `plasmoidviewer -a brand/plasmoid/org.nemesis.themecontrols` (with `plasma-sdk`) or, once user-staged, `plasmawindowed org.nemesis.themecontrols`. Verify hover, click, tab/space, focus visibility, cyan/strong-focus toggles, reset, two display scale factors and removal. Remove the widget from all desktops/panels before running `dragonized.sh uninstall`.

## References

- KDE Plasma 6 widget setup: https://develop.kde.org/docs/plasma/widget/setup/
- KDE Plasma 6 porting: https://develop.kde.org/docs/plasma/widget/porting_kf6/
- KDE widget testing: https://develop.kde.org/docs/plasma/widget/testing/
- Qt Quick Controls: https://doc.qt.io/qt-6/qtquickcontrols-index.html

## Source and headless interaction acceptance — 2026-11-19

**ACCEPTED at the source/component gate, not the physical GUI gate.** [GitHub Arch Docker run 44613035058](https://github.com/pskeffington/nemesis/actions/runs/44613035058) installed official Qt 6.12 packages in an ephemeral, unprivileged container, parsed the QML, executed eight interaction assertions (10 total including QtTest lifecycle), and staged the widget/icons into a separate ArchISO profile with unchanged baseline rescue contents. Python tests also verified all eight mirrored SVGs, QML metadata, accessible labels, minimum color contrast and no hidden shell/network/device actions. [Brand fixture CI 44613035166](https://github.com/pskeffington/nemesis/actions/runs/44613035166) passed.

The initial QtTest run failed pointer tests because its `TestCase` root was invisible. The fixture now specifies `visible: true` and retains strict pointer click and intermediate-state assertions; the passing run exercises actual mouse and keyboard events. Do not interpret this as proof of a working Plasma panel or Garuda workstation. Physical review remains in [issue #6](https://github.com/pskeffington/nemesis/issues/6).
