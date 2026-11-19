# Nemesis: Garuda Dr460nized Theme Operability (B06-P04)

This is an opt-in, **per-user** KDE Plasma 6 appearance preview. It does not replace Garuda's global theme, Kvantum, panels, window decorations, login manager or a tested Nemesis ISO. Run the Nemesis script without sudo; only optional prerequisite installs use sudo.

## First run on the Dragonized test machine

~~~bash
sudo pacman -S --needed git python librsvg

# In an existing Nemesis clone
git fetch origin feat/nemesis-brand-v0-1
git switch feat/nemesis-brand-v0-1

# Diagnostic and dry run; neither changes your settings
bash brand/scripts/dragonized.sh doctor
bash brand/scripts/dragonized.sh plan

# Stage assets without changing the desktop
bash brand/scripts/dragonized.sh install
bash brand/scripts/dragonized.sh status

# Explicitly apply KDE colors, saving previous scheme
bash brand/scripts/dragonized.sh apply

# Optional separate Plasma Style preview, saving previous style
bash brand/scripts/dragonized.sh apply-style

# Optional original vector -> 4K wallpaper conversion
bash brand/scripts/dragonized.sh render-wallpaper
bash brand/scripts/dragonized.sh status
~~~

For a fresh clone: first run git clone --branch feat/nemesis-brand-v0-1 --single-branch https://github.com/pskeffington/nemesis.git, then cd nemesis. Konsole profile selection and wallpaper choice are **manual** changes in System Settings; they are not changed by these commands.

## Restore and uninstall

~~~bash
bash brand/scripts/dragonized.sh restore-style
bash brand/scripts/dragonized.sh restore
bash brand/scripts/dragonized.sh uninstall
bash brand/scripts/dragonized.sh status
~~~

If you manually selected a Nemesis Plasma Style, Konsole profile, or wallpaper, change that selection back first. Uninstall refuses to remove a selected resource, an unexpected symlink, an altered managed file or a filename it does not own. A failed apply which changes KDE settings keeps the saved recovery state.

## Command matrix

| Action | Files or settings changed | Exit conditions |
| --- | --- | --- |
| doctor | None | Read-only compatibility, command availability and collision diagnostics |
| plan | None | Read-only file plan |
| install | Owned XDG data files only | Refuses unowned/modified targets |
| apply | KDE color only, recovery state | Requires live KDE, previous named scheme and Plasma color tool |
| apply-style | Plasma Style only, independent recovery state | Requires live KDE, previous named style and Plasma desktoptheme tool |
| render-wallpaper | New owned 3840x2160 PNG | Requires optional librsvg; manual selection |
| restore-style | Prior style restored when Nemesis remains active | Leaves separately changed style untouched |
| restore | Prior KDE color restored when Nemesis remains active | Leaves separately changed color untouched |
| uninstall | Hash-verified owned files removed | Blocks live references and modified or unsafe paths |
| status | None | Reports active schemes and ownership checks |

Source theme still inherits standard Breeze artwork. The Nemesis application icon is not a full icon-theme replacement. Plasma Style and color choices may be overridden by Garuda's Kvantum integration on relogin; document this before any packaging decisions.

## Physical acceptance

Check the console and actual Plasma UI before/after applying and after relogin: legibility, focus rings, selected text, Konsole, panel contrast, wallpaper on each display, and full restoration. Record Plasma version, session type, Garuda theme package version, exact commands and exit codes; redact usernames, serial numbers and network details.

**Static fixture checks do not establish live KDE acceptance.** Track the remaining physical gate in https://github.com/pskeffington/nemesis/issues/6 and do not merge draft PR #5 until evidence is reviewed.

References: https://develop.kde.org/docs/plasma/theme/theme-details/ and https://wiki.garudalinux.org/en/customization/dr460nized/

## Interactive Plasma object test (optional)

The theme installer now stages `org.nemesis.themecontrols` (Plasma 6 metadata and QML) and eight extra hicolor SVG icons. This is an **inspectable theme preview**, not an operator-control dashboard.

After installing the theme with `bash brand/scripts/dragonized.sh install`, a user in a Plasma 6 test session can choose **Add Widgets → Nemesis Theme Inspector** and inspect selection, hover, focus, accent, reset, keyboard Space and Enter. Alternatively run `plasmawindowed org.nemesis.themecontrols` in the user session if supported. Neither action is executed automatically by the installer.

Before uninstalling, remove that widget from any desktop/panel; the installer refuses to delete an applet still referenced in Plasma's user configuration. Existing manual wallpaper/Konsole and Plasma Style restoration rules still apply.

See [object contract](INTERACTIVE_OBJECTS.md). GitHub's headless Qt6 tests do not prove real Plasma/Kvantum integration or panel behavior.
