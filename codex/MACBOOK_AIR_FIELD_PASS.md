# MacBook Air field edition — Codex pass queue

**Current phase:** repository source engineering. GitHub-hosted Docker compilation is allowed only under previously approved scope. No local Linux/Mac deployments, QEMU, USB flashing or firmware/disk changes.

## F03-A01 — Air source baseline

**Owner:** macbook-air-field-engineer. **Deliverables:** `spec/macbook-air-field.json`, `profiles/macbook-air-field/packages.x86_64`, `nemesis-field-check`, `tests/test_macbook_air_field.py` and source research.

**Gate:** GitHub Python/fixture/ShellCheck all pass, existing `mac-intel` package manifest and builder unchanged, Air field layer remains unselected and T2/ARM excluded. **Source-only gate**; not an ISO build or hardware acceptance.

## F03-A02 — opt-in edition integration (next engineering design)

1. Inspect actual installed ArchISO `releng` and `baseline` source contracts.
2. Propose a named `macbook-air-field` staging path that adds *only* the optional four-package delta and read-only diagnostic; never modify the verified default Intel rescue profile.
3. Require schema and source tests for package deduplication, profile identity and diagnostic executable permission, no default power daemon, no auto Broadcom driver and no boot-entry mutation.
4. Document exact expected ISO delta, package origins, user-space service behavior and source rollback.
5. Stage in native Arch CI and, **only after an explicitly scoped approval**, attempt a new isolated Docker ISO build. Do not infer success from prior generic Intel build.

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
