# R29-03 — Nemesis Operator offline field console

**Scope:** GitHub source and GitHub-hosted static/native ArchISO checks. This is a lightweight, on-demand aid for a hypothetical civil-resilience exercise; it is not a prediction about autonomous robots or a remote-sensing/tracking product. No local Mac/Garuda installation, physical device access, network scan, QEMU/Wayland session or external capture has been performed.

## Exact on-image components

| Entry point | Source location | Use | Automatic action |
| --- | --- | --- | --- |
| **Offline Coordinate Viewer** | `profiles/mac-intel-operator/airootfs/usr/share/nemesis-operator/offline-field-map.html` | File picker for trusted GeoJSON; draw longitude/latitude geometries on an original canvas | None: no network fetch, position, tiles, storage or startup |
| **Field Notes (Manual)** | `profiles/mac-intel-operator/airootfs/usr/local/bin/nemesis-field-note` | User-directed categorized text notes in a private local SQLite database | None: no background process or auto export |
| Menu entries | `.../usr/share/applications/nemesis-operator-{offline-map,field-notes}.desktop` | Explicit browser/terminal launcher | No autostart |
| Data model | `spec/offline-field-console.json` | Auditable capabilities, privacy contracts and staging gates | Source only |

The existing `https://globe.airplanes.live/` wallpaper is unchanged. Its remote content is an **online aircraft map**, not an offline navigation or robot-detection source. Its standalone offline standby page remains separate from this local coordinate viewer.

## Operator manual

**Offline viewing:** open the Offline Coordinate Viewer from the KDE menu, choose a user-supplied `.geojson` or `.json` file, and inspect drawn points/lines/polygons. The single-page app is entirely local, enforces CSP `connect-src 'none'`, and ignores feature properties. It accepts at most 5 MiB / 2,500 features / 30,000 vertices. It does not request location permission, use third-party fonts/scripts or contact a map service. The plot is **equirectangular**, so dateline-crossing features and distances are not reliable for field routing. The page contains no roads, terrain, authoritative boundaries, tiles, local street directory or turn-by-turn pathfinding; verify imported files against trusted sources.

**Manual notes:** open a terminal as the nonprivileged `operator` user:

```text
nemesis-field-note add --category observation --text "Equipment inspected"
nemesis-field-note list --limit 10
nemesis-field-note status
nemesis-field-note export --output /path/to/new-private-export.jsonl
```

Categories: `observation`, `navigation`, `supply`, `system`, `safety`. Notes are limited to 500 characters with no control characters. Only UTC timestamp, chosen category, text and monotonically increasing local ID are stored; no GNSS coordinate, MAC address, SSID, camera photo, microphone, SDR sample, remote server or device telemetry is collected automatically.

**Security and retention:** first manual use creates `~/.local/share/nemesis-operator` mode **0700** and a SQLite DB mode **0600**. The command rejects root use, symlinked database/directory, invalid categories and oversized text. Export creates a **new** 0600 JSONL file and refuses an existing destination; the user controls where to write it. On ephemeral live media, records will be lost when the session/overlay is destroyed unless manually exported. On a later installed edition, storage/encryption/retention and authentication need a separate design; do not copy live-only autologin/lock settings.

## Lightweight and portable

Only the Python standard library and the existing Firefox are used. The source adds an explicit `python` package request to Operator core for reproducibility; current ArchISO `releng` already depends on Python through its installer, so actual incremental footprint requires dependency inventory evidence rather than assumptions. No QGIS, GNSS daemon, GeoServer, tile server, JSON mapping framework or JavaScript package manager is installed.

## Acceptance and open gates

| Pass | Acceptance test | Status |
| --- | --- | --- |
| R29-03a | Python unit tests: manual add/list/status, private DB, export/non-overwrite, symlink rejection, input bounds and static network policy | **PASS — 40 tests**, [CI 44804592372](https://github.com/pskeffington/nemesis/actions/runs/44804592372), source `da112193` |
| R29-03b | ShellCheck, synthetic and native signed ArchISO Operator staging includes files and execute permissions, preserves rescue/Air profiles | **PASS**, [CI 44804592390](https://github.com/pskeffington/nemesis/actions/runs/44804592390), source `da112193` |
| R29-03c | Built Operator SquashFS includes notebook/viewer/launchers and privacy constraints; original wallpaper intact | NOT RUN on this branch |
| R29-03d | Real Firefox `file://` import and Canvas rendering, keyboard/reader accessibility, 4-GiB Mac use | NOT TESTED |
| R29-04 | Reviewed optional Meshtastic and Remote ID adapters | DEFERRED |
| R29-05 | Licensed offline street basemap, routing, reliability and recovery | NOT IMPLEMENTED |

**Source evidence:** [R29-03 machine-readable contract](../spec/offline-field-console.json). Runtime acceptance must never be inferred from static tests, Docker ISO compilation, or a screenshot of a coordinate grid.

## Follow-up design (not enabled)

- **Off-grid text:** choose a tested Meshtastic radio/phone and an opt-in local Bluetooth/USB bridge. Require explicit pairing, permissions and address/privacy controls; no automatic scan, public location broadcast, radio capture, or background remote service.
- **Broadcast Remote ID:** accept only observed, legitimately broadcast identifiers from operator-selected compatible receivers. Detection is incomplete, and absence of a broadcast never proves an empty sky; do not classify intent or track people.
- **Geographic data:** add a user-selected, licensed regional basemap cache or signed GeoJSON/GeoPackage import only after geographic scope, license/attribution, storage footprint and source freshness are established. Avoid automatic bulk downloads and do not publish private route notes.

Project owner: operator-desktop-engineer; reviewers: build-qa-engineer, security-release-reviewer. Roll back by omitting the Operator-only overlay files; generic rescue and Air images remain independent.
