# Nemesis Project — Brand Asset Workstream v0.1

This track converts the approved Nemesis branding board into separate, versioned deliverables. It does not replace the Mac-first distro engineering roadmap or imply an ISO/theme has been deployed.

**Visual reference:** purple angular Nemesis emblem, dark hooded raptor, misty mountains and communications station, cyan signal/radar HUD, silver wordmark. Use original artwork and avoid external copyrighted character or logo designs.

## Garuda Dr460nized preview deployment

The phase B06 test kit is staged from this branch without replacing Garuda's theme. See [Dragonized deployment and rollback](DRAGONIZED_TESTING.md). Use `bash brand/scripts/dragonized.sh plan`, then `install` and optionally `apply` inside KDE; use `restore` and `uninstall` afterward. The experimental Plasma style and vector wallpaper are separate optional layers; live Dragonized validation remains pending.

## Deliverable directory
| ID | Segment | Deliverable | State |
|---|---|---|---|
| B01 | Logo & colors | `brand/identity` vector symbol, wordmark, palette | REVIEW |
| B02 | Social icons | Square 16–1024px, circular avatar, favicon | REVIEW (raster pack separately) |
| B03 | Banners | GitHub 1280x320, LinkedIn 1584x396, X 1500x500, YouTube 2560x1440 | REVIEW (raster pack separately) |
| B04 | Wallpapers | Four 3840x2160 variants; ultrawide/mobile | REVIEW (raster pack separately) |
| B05 | Iconography | `brand/icons` SVG glyphs | REVIEW |
| B06 | Desktop color | `brand/theme` KDE/Konsole preview | REVIEW; live test pending |
| B07 | Agent | `agents/arch-theme-creative-developer.md` | REVIEW |

The 2026-11-19 ZIP delivered in the project conversation contains the approved board, raster exports, 4K wallpapers, original refined icon artwork, QA manifest and a visual preview. This Git branch contains source text and vector assets; it **does not** assert that those raster files were uploaded to GitHub.

See [brand guide](BRAND_GUIDE.md) and [delivery gates](ROADMAP.md).

## Test-machine operability

For per-user deployment on Garuda Dr460nized, follow [OPERABILITY.md](OPERABILITY.md). Begin with the read-only doctor and plan checks. Colors and Plasma Style can be explicitly applied and separately restored. Testing on an actual Plasma 6 desktop remains open in GitHub issue #6.

## Experimental ISO artwork staging

The Mac-first ISO can stage an optional KDE preview from this same asset source under the **separate** `mac-intel-theme-preview` build target. See [ISO overlay and Docker test policy](../docs/THEME_ISO_PREVIEW.md). The base rescue image remains unthemed, and only GitHub-hosted Docker tests are authorized; no boot, graphical login, or physical Mac success is implied.
