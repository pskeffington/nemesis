# F06-ISO-01 — Optional Nemesis KDE theme in the ArchISO profile

**Scope authorized:** prepare an opt-in theme-bearing ISO candidate inside GitHub and validate its staging in GitHub-hosted Docker. Current repository-foundation restrictions remain: no access to the user's Garuda workstation, Mac, SSH, USB, EFI settings, partitions, or QEMU. **This is not a distribution release or boot-verified desktop.**

## Separate build identities

| Build target | Behavior | Acceptance |
| --- | --- | --- |
| mac-intel (default) | Normal ArchISO releng plus non-T2 Intel hardware diagnostics; no KDE theme payload | Unchanged rescue baseline |
| mac-intel-theme-preview (explicit selection) | Same Intel rescue sources plus signed-Arch KDE package names and Nemesis system-wide theme assets | Experimental, Docker staging only until further CI |

The preview is a **development target**, not the planned production mac-intel-desktop edition in spec/editions.json; no declarative resolver or automated installer is activated. Do not change the published edition contract to a supported state until the F02/F04 dependency, security and license gates pass.

## Source and filesystem layout

Authoritative input assets remain under brand/. The opt-in staging script is scripts/prepare-theme-profile.sh, and its separate package additions are profiles/mac-intel-theme-preview/packages.x86_64.

Staging copies official ArchISO releng with existing scripts/prepare-profile.sh, preserves the original boot directories and pacman.conf, then installs:

| Path inside preview ISO | Function |
| --- | --- |
| /usr/share/color-schemes/Nemesis.colors | KDE/Qt color preset |
| /usr/share/konsole/Nemesis.colorscheme | Konsole color preset |
| /usr/share/plasma/desktoptheme/Nemesis/ | Plasma 6 Style with Breeze fallback |
| /usr/share/icons/hicolor/scalable/apps/nemesis.svg | Single app icon, NOT a full icon-theme override |
| /usr/share/wallpapers/Nemesis/metadata.json | Wallpaper plugin metadata |
| /usr/share/wallpapers/Nemesis/contents/images/3840x2160.png | Native PNG rendered from original scalable SVG |
| /usr/share/nemesis/brand/signal-dusk.svg | Original SVG wallpaper source |
| /usr/share/licenses/nemesis-theme-preview/LICENSE | Source repository license |
| /usr/local/bin/nemesis-theme-report | Read-only in-image asset presence summary |

There is no autologin, SDDM service enablement, default desktop session, system-wide forced Plasma style, live-user credentials, network service, hardware policy change, or installation action. Having KDE packages in a built ISO does not prove that a KDE graphical session can start or that it boots on an Intel Mac.

## CI validation in GitHub

1. **Unprivileged staging:** .github/workflows/theme-iso-stage.yml mounts the feature branch checkout read-only into an ephemeral official Arch container. It installs official ArchISO, librsvg and validators, stages both profiles under temporary container storage, checks the core isolation, copied assets, 4K PNG dimensions, manifest uniqueness, package availability and EFI/GRUB preservation.
2. **Privileged ISO compilation:** existing .github/workflows/docker-archiso.yml keeps its trusted-main-only restriction. Once reviewed code lands on main, its manual workflow-dispatch option can explicitly select mac-intel-theme-preview; the default remains mac-intel. It records mkarchiso exit, checksum and UEFI El Torito **metadata**, not boot.
3. **Future GUI/VM/physical:** QEMU/OVMF, SDDM/Plasma login, screenshot legibility, Dragonized Kvantum interoperability, Apple hardware and installer recovery are separate open acceptance gates; do not infer success from Docker.

## Reproducible trusted Docker invocation

The Docker ISO workflow is the only authorized privileged image build path. On GitHub Actions, use **Actions → Nemesis Docker ArchISO ISO build → Run workflow**, then choose the edition. Never run privileged Docker on a pull-request source or a personal workstation. A full theme ISO build is a later deliberate decision, not triggered by the staging PR checks.

The standalone scripts/build-iso.sh mac-intel-theme-preview is a source-controlled future invocation used **inside that trusted workflow**; old local-host runbooks remain NO-GO until explicit human handoff.

## Gates and rollback

- Gate F06-ISO-S: source/renderer/package metadata staging in unprivileged Docker, with proof of untouched mac-intel.
- Gate F06-ISO-B: trusted-main Docker mkarchiso of preview target with SHA-256 and El Torito report. No boot claim.
- Gate F06-ISO-G: authorized KDE/SDDM graphical login and accessibility/rollback inspection in a dedicated VM; NOT STARTED.
- Gate F06-ISO-M: authorized physical non-T2 Mac device check; NOT STARTED.

Rollback for source only: revert this opt-in branch commit. Baseline rescue build remains default and separately named. Preserve Docker logs and checksums only as test evidence; never publish preview ISO as an accepted release.

References: ArchISO profile schema https://github.com/archlinux/archiso/blob/master/docs/README.profile.rst and KDE style layout https://develop.kde.org/docs/plasma/theme/theme-details/.

## Verified source-stage gate (2026-11-19)

**F06-ISO-S ACCEPTED — source and unprivileged Arch container staging only.** [GitHub Docker run 44611079852](https://github.com/pskeffington/nemesis/actions/runs/44611079852) verified copied ArchISO releng, the isolated theme payload, official package metadata lookups, actual 3840×2160 render, unchanged baseline rescue profile and boot files, and non-overwrite protection. [Static CI 44611206411](https://github.com/pskeffington/nemesis/actions/runs/44611206411) passed after a ShellCheck provenance-log formatting correction; [foundation CI 44611206246](https://github.com/pskeffington/nemesis/actions/runs/44611206246) also passed. This status does not certify a completed ISO file.

**Next gate:** [F06-ISO-B01 issue #14](https://github.com/pskeffington/nemesis/issues/14) requests an explicitly selected trusted-main Docker image compilation after PR review, SHA-256 verification and inspection of the **built** squashfs for theme files. The desktop boot, Dragonized UI acceptance and physical Intel Mac remain untested.

## B11 — Interactive objects carried by the opt-in ISO

The optional `mac-intel-theme-preview` stage also carries the self-contained Plasma 6 applet package `/usr/share/plasma/plasmoids/org.nemesis.themecontrols/` (metadata, three QML source files and eight icon SVGs), plus separately named `nemesis-*.svg` icons under `/usr/share/icons/hicolor/scalable/apps/`. Both are absent from the default mac-intel rescue stage. The widget is **not activated** and no panel, autologin or network service is configured.

The unprivileged Arch Docker test now validates copied source equality for the whole widget; Qt6's headless `qmltestrunner` tests click, keyboard selection, accent and reset behavior. This is a source/package/runtime-component gate, not a successful Plasma shell session or a bootable desktop test. See [object behavior spec](../brand/INTERACTIVE_OBJECTS.md). Hardware and privileged full ISO gates remain unchanged.
