# B12 — Reuse approved Nemesis branding in the Operator ISO

**Status:** REVIEW — branch source committed; CI and real Operator ISO staging remain separate acceptance gates.

## Authority and design contract

This pass reuses the established brand masters rather than generating alternate colorways: `brand/identity/tokens.json`, `brand/theme/kde/Nemesis.colors`, eight canonical SVGs, and the existing Plasma 6 Theme Inspector. Violet `#883DFF`, cyan `#00A8FF`, and navy `#0B0E14` are unchanged. The Operator ISO keeps `https://globe.airplanes.live/` as the live background, and keeps its original offline fallback.

## Source implementation

`scripts/stage-operator-brand.sh ABSOLUTE_STAGED_OPERATOR_PROFILE` copies the pre-existing color scheme, Konsole palette, Plasma Style resources, emblem, wordmark, dusk SVG fallback, standalone interactive inspector, and eight SVG icons into a *previously prepared* `nemesis-operator` profile.

No copied asset auto-activates a widget or replaces wallpaper, login configuration, panel layout, KDE settings, or the offline map. The script rejects non-Operator profiles, symlinked sources, divergent canonical icon mirrors, and destination collisions before copying. The staging operation is intentionally one-shot.

`tests/test-operator-brand-staging.sh` creates disposable source fixtures, checks icon parity and no autostart changes, tests a collision on second run, and verifies that a rescue image is rejected. `.github/workflows/brand.yml` invokes this test.

## Critical integration dependency

The branding branch was created before the newest mainline Operator files: `scripts/prepare-operator-profile.sh`, `spec/operator-edition.json`, the Docker Operator workflow, and related tests. **Do not replace the latest main version of those files with older theme-branch copies.**

After reconciling branch against current main, insert precisely one invocation in `scripts/prepare-operator-profile.sh` after its existing overlay and source asset setup:

```bash
bash "$root/scripts/stage-operator-brand.sh" "$dest"
```

This must run only after `iso_name="nemesis-operator"` is installed into `profiledef.sh`. Reconcile source permissions, ensure new files are included in Docker image context, and extend `tests/test-operator-profile.sh` to compare copied assets with brand masters. No brand wallpaper selection is performed because the live globe remains the central Operator background.

## Acceptance sequence

1. **Source fixture:** brand CI passes for B12; compare source, binaries and metadata.
2. **Mainline reconciliation:** preserve existing Operator packages, XDG autostart, live-only screen-lock safeguard, and compiled MIT wallpaper pin. Resolve merge conflicts without force.
3. **Docker staging:** existing Operator Docker staging and brand fixtures pass together, including exact SVG equality and absence of changes to rescue/lean image profiles.
4. **Built ISO:** `mkarchiso` succeeds with verified SquashFS payload and checksums. A source staging pass is not an ISO acceptance.
5. **Graphical runtime:** verify live map layering, KDE color scheme, icon dimensions, keyboard focus, widget opt-in, offline fallback, reboot recovery and actual Intel Mac battery/GPU use.

**Rollback:** remove the single staging invocation and revert the B12 script/test additions. Previously accepted rescue and Operator mainline resources must remain intact.
