# Nemesis edition and package-layer contract

**Current phase: repository-only foundation engineering.** This specification is a planning and source-validation artifact, **not** a build-time input to `mkarchiso`. No hardware support, boot success, installer behavior or image release is implied.

## Authority and boundaries

`spec/editions.json` is the machine-readable contract for candidate platforms and planned editions. `profiles/mac-intel/` remains the *actual* source overlay for the current scaffold. `scripts/prepare-profile.sh` is still the only implemented profile staging path. A future resolver may consume this JSON **after review and tests**, but must not silently change image contents.

### Layering

1. `arch-releng`: signed official ArchISO releng, copied at execution time; not vendored or declared to be bit-for-bit pinned yet.
2. `intel-hardware-overlay`: committed x86_64 baseline manifest and read-only hardware report.
3. `mac-desktop-kde`: planned optional user interface and accessibility; does not auto-enable Plasma for the current ISO.
4. `field-operator`: planned optional hardware/operator tools, never bundled into the rescue ISO by default.
5. `t2-support`: research-only T2 kernel/device/firmware, separate build and security gates.
6. `asahi-platform`: research-only ARM64 Apple Silicon boot chain, not a renamed Intel image.

The `status` field distinguishes the *presence of source scaffolding* from operational acceptance. `source-scaffold` is not an assertion that the ISO has built or booted. Fields for planned edition build scripts and manifests must remain `null` until genuine implementations exist.

## Package policy

- Official Arch signed repositories by default; external repos undergo supply-chain and signature review.
- Do not redistribute Apple firmware, auto-extract firmware, embed secrets, or automate internal disk writes.
- Broadcom and other drivers are chosen against model/PCI IDs and then validated; avoid universal WLAN hacks.
- Keep core, Mac hardware, desktop, and operator editions separately reviewable to prevent baseline bloat.
- No promise of compatibility for T2 or Apple Silicon from any Intel ISO/CI pass.

## Contract checks

```bash
python3 -m unittest discover -s tests -p 'test_foundation.py' -v
```

Tests check data uniqueness, architecture/platform separation, referenced files, empty implementation pointers for speculative editions, no execution claims, the base package manifest, and repository safety defaults. GitHub Actions runs this Python-only test without any local Linux deployment.

## Change control

Changes to `spec/editions.json` need an ADR, a foundation/edition task ID and a passing repository contract test. A new buildable edition requires its own manifest, scripts, source provenance, signed package policy and *separate build/boot/hardware evidence*. See `docs/FOUNDATION_PRIORITY_PLAN.md` and `codex/REPOSITORY_PHASE_PROMPT.md`.

**Handoff expectation:** the implementation Codex should consume these contracts, inspect existing source, report mismatches and work through explicitly assigned pass gates—not interpret a roadmap row as permission to run root, flash devices or build an ISO.

## F02 package-layer extension

The [package composition contract](PACKAGE_COMPOSITION.md) and [`spec/package-layers.json`](../spec/package-layers.json) define dependency ordering, fail-closed conflicts, signed-source defaults and platform exclusions. Eleven GitHub source tests passed [CI 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336). The contract is **not consumed by the current builder** and does not change the ISO.
