# Nemesis theme on Garuda Dragonized (Plasma 6) — test runbook

**Status:** preview installer, staged source; local fixture tests only. No live Dragonized workstation test is recorded yet. This is an optional appearance overlay, **not** a replacement for Garuda's Global Theme, Kvantum, panel layouts, boot graphics, login manager, or Nemesis distro hardware gates.

## 1. Preflight

Run in your **normal user session** (no sudo for the theme script):

~~~bash
cat /etc/os-release
plasmashell --version
printf 'Session: %s | Desktop: %s\n' "$XDG_SESSION_TYPE" "$XDG_CURRENT_DESKTOP"
pacman -Q garuda-dr460nized plasma-workspace 2>/dev/null || true
~~~

If Python/Git are missing, install prerequisites once (this package command alone uses sudo):

~~~bash
sudo pacman -S --needed git python
~~~

## 2. Clone test branch and inspect changes

~~~bash
git clone --branch feat/nemesis-brand-v0-1 --single-branch https://github.com/pskeffington/nemesis.git
cd nemesis
bash brand/scripts/dragonized.sh plan
~~~

If you already cloned the repository:

~~~bash
git fetch origin feat/nemesis-brand-v0-1
git switch feat/nemesis-brand-v0-1
bash brand/scripts/dragonized.sh plan
~~~

**Safety:** no pacman operations, root writes, global theme changes, boot manager changes, panel changes or Kvantum edits are performed by this script. It refuses an unowned filename collision and does not overwrite user-edited managed assets.

## 3. Install test assets (no visual changes yet)

~~~bash
bash brand/scripts/dragonized.sh install
bash brand/scripts/dragonized.sh status
~~~

Installs in your XDG data home (normally ~/.local/share):
- color-schemes/Nemesis.colors — Qt/KDE color scheme
- konsole/Nemesis.colorscheme — terminal palette
- plasma/desktoptheme/Nemesis/{metadata.json,colors,plasmarc} — optional experimental Breeze-fallback Plasma style
- icons/hicolor/scalable/apps/nemesis.svg — standalone Nemesis app icon (not an icon-theme replacement)
- wallpapers/Nemesis/signal-dusk.svg — original vector master

## 4. Apply the reversible color layer

~~~bash
bash brand/scripts/dragonized.sh apply
bash brand/scripts/dragonized.sh status
~~~

The apply step requires an active KDE session, reads the prior named scheme from kdeglobals, records it under ~/.local/state/nemesis-theme/state.json, and applies **only** the new color scheme with Plasma's tool. If the current color scheme cannot be read, the script refuses to apply; select Nemesis manually in **System Settings → Colors & Themes → Colors** instead.

For Konsole: **Settings → Edit Current Profile → Appearance → Nemesis Dark**. Selecting a Konsole scheme is a separate manual step. If your terminal is Kitty or another application, its colors are unaffected.

**Do not select Nemesis Preview under Plasma Style until after the color-only pass.** It is available for an isolated second test: System Settings → Colors & Themes → Plasma Style → Nemesis Preview. This changes Plasma panel styling by user choice, not by the script; restore the original Dr460nized Plasma Style in System Settings when finished. No PLM/SDDM, GTK, cursor, Aurorae, dock, or Kvantum configuration is changed.

Garuda's Dr460nized Kvantum settings may override some accent colors, especially after a new session. Record this as an observation rather than removing Dr460nized packages.

## 5. Optional 4K wallpaper

The supplied SVG is resolution-independent. For a native 3840×2160 PNG, install the converter then render:

~~~bash
sudo pacman -S --needed librsvg
bash brand/scripts/dragonized.sh render-wallpaper
~~~

Output: ~/.local/share/wallpapers/Nemesis/signal-dusk-3840x2160.png (or under XDG_DATA_HOME). Select that image manually in Plasma's wallpaper settings. The installer does **not** alter your existing wallpaper selection.

## 6. Revert or uninstall

~~~bash
bash brand/scripts/dragonized.sh restore
bash brand/scripts/dragonized.sh uninstall
bash brand/scripts/dragonized.sh status
~~~

Restore reapplies the previously recorded color scheme when Nemesis is still active. Uninstall removes **only hash-verified files owned by this installer** and refuses files modified after installation. Other changes made manually through KDE settings (wallpaper, Plasma Style, Konsole profile selection) must also be reverted manually first, as they are not managed by the CLI.

## 7. Physical QA gate

Record: plasmashell --version, XDG_SESSION_TYPE, installed garuda-dr460nized package version, native resolution, and visual evidence for Colors, Konsole, wallpaper, panels, focus visibility, and restoration. Check both light/dark text and selected text readability; test logoff/logon for Kvantum interference. Keep screenshots free of local network IDs and sensitive paths. Submit a defect for any crash, theme collision, unexpected style reset, or incomplete restore.

**Acceptance:** successful user-space stage, explicit reversible color apply, stable desktop after logout/login, legible UI, and complete restoration without edits to Garuda-managed system files. Local fixture tests alone do not satisfy this gate.

## Grounded references

- https://develop.kde.org/docs/plasma/ — user-space path and color-scheme semantics
- https://develop.kde.org/docs/plasma/theme/theme-details/ — Plasma style metadata, fallback and colors
- https://wiki.garudalinux.org/en/customization/dr460nized/ — Garuda Kvantum color interaction
- https://forum.garudalinux.org/t/garuda-linux-temeraire-260819/48606 — August 2026 Plasma login/theme changes

## Operability extensions (phase B06-P04)

The initial color-only command remains supported. Run bash brand/scripts/dragonized.sh doctor for read-only compatibility diagnostics before installing. Optionally use bash brand/scripts/dragonized.sh apply-style to preview the Nemesis Plasma Style separately from colors; the previous Plasma Style is saved independently. Undo via restore-style and restore before uninstall. This does not replace the Dr460nized Global Theme or change Kvantum or panels.

Uninstall now refuses to remove resources still selected by Plasma Style, the wallpaper configuration, or a Konsole profile. See brand/OPERABILITY.md for commands and recovery details. Actual Dragonized workstation evidence remains outstanding.
