# MacBook Air field edition — Codex pass queue

**Current phase:** repository source engineering. GitHub-hosted Docker compilation is allowed only under previously approved scope. No local Linux/Mac deployments, QEMU, USB flashing or firmware/disk changes.

## F03-A01 — Air source baseline

**Owner:** macbook-air-field-engineer. **Deliverables:** `spec/macbook-air-field.json`, `profiles/macbook-air-field/packages.x86_64`, `nemesis-field-check`, `tests/test_macbook_air_field.py` and source research.

**Gate:** GitHub Python/fixture/ShellCheck all pass, existing `mac-intel` package manifest and builder unchanged, Air field layer remains unselected and T2/ARM excluded. **Source-only gate**; not an ISO build or hardware acceptance.

## F03-A02 — opt-in Air ISO builder (source committed, Docker acceptance pending)

1. Inspect `scripts/prepare-air-field-profile.sh`, `scripts/build-air-field-iso.sh`, `tests/test-air-profile.sh` and installed ArchISO `releng`/`baseline` source contracts.
2. Propose a named `macbook-air-field` staging path that adds *only* the optional four-package delta and read-only diagnostic; never modify the verified default Intel rescue profile.
3. Require schema and source tests for package deduplication, profile identity and diagnostic executable permission, no default power daemon, no auto Broadcom driver and no boot-entry mutation.
4. Document exact expected ISO delta, package origins, user-space service behavior and source rollback.
5. Verify current GitHub static/fixture source checks and the [isolated Air Docker build](https://github.com/pskeffington/nemesis/actions/runs/44612684836). Do not infer success from prior generic Intel build and never claim actual Mac boot.

## F03-A03 — field hardware and network readiness (future authorization required)

- Choose exact Air model/PCI IDs and physical recovery plan.
- Verify USB Ethernet/tether and internal Broadcom driver provenance before expecting Wi-Fi.
- Supervise 10 reconnect tests, 10 lid/suspend cycles, an extended battery/thermal observation and 30-minute USB SDR capture.
- Record 4-GiB-class memory/SSD effects, input/accessibility, offline data and return to macOS.
- Keep every result NOT TESTED until observed. No automatic APFS, disk, Wi-Fi, fan or kernel tuning.

## F03-A04 — lean UI and RF integration (design only)

- Compare minimal KDE desktop settings against measured RAM and battery usage; preserve captioning and keyboard usability.
- Keep mapping, SDR decoders, GNSS, external sensor stacks and remote access as optional install profiles.
- Verify supply-chain/release policy separately under F04.

**Report:** current source SHA, role, changed files, exact GitHub CI results, separate build/boot/hardware gates, unresolved model issues and next repo-only pass.
