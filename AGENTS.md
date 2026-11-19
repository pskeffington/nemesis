# Nemesis contributor / Codex operating contract

## Source of truth
- Work in this repository for distro profiles, source, build scripts, compatibility claims and release evidence.
- Read README.md, ROADMAP.md and docs/ARCHITECTURE.md before changing architecture.
- `linux_config` is related machine configuration, not a source of unreviewed files to bake into ISOs.
- Preserve existing GPL-3.0 LICENSE and attribution; review upstream dependencies and firmware redistribution terms.

## Platform boundaries
- First implemented image: x86_64 Intel Macs **without T2** via official ArchISO releng.
- T2 support requires its own reviewed kernel, firmware and physical hardware gates; never claim the stock kernel solves T2 input/audio/Wi-Fi.
- Apple Silicon requires a distinct ARM64 boot architecture and upstream Asahi evaluation; never claim an x86_64 ISO boots M-series Macs.
- Prioritize Mac EFI, Broadcom chipset identification, audio, GPU, trackpad, thermal and battery diagnostics before GUI theming.
- Never automatically extract Apple firmware, distribute unlicensed firmware, disable secure-boot policies, or alter internal disks.

## Every executable pass
1. Inspect existing code and compatibility matrix.
2. Implement one reversible, testable change with named file paths.
3. Run `bash scripts/validate.sh`; run `mkarchiso` and VM/physical hardware checks when the environment permits.
4. Update ROADMAP.md evidence and docs/MAC_COMPATIBILITY.md for any newly tested hardware.
5. Mark `ACCEPTED` only with identifiable evidence; otherwise label `READY`, `IN PROGRESS` or `BLOCKED`.
6. Exclude secrets, local network topology, Mac serial numbers, user data, raw firmware dumps and proprietary captures from commits.

## Build and review guardrails
- No host install scripts that write to Mac partition tables or firmware as a default.
- Every script: `set -euo pipefail`, human-facing comments, explicit prerequisites and predictable failures.
- Validate syntax with `bash -n`, lint with ShellCheck, inspect output artifacts, record SHA-256.
- Use official Arch packages by default; external AUR, T2 and Asahi sources require explicit provenance review.
- Distinguish upstream documentation, proposed compatibility and observed physical testing.
- Do not add repo pricing or business valuation data.
