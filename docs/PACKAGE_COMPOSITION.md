# F02 — package composition and layer policy

**Mode:** repo-only specification; **no new package resolver is active**. This source design does not add packages to an ISO or execute any commands on Garuda.

## Source of truth

- Machine-readable proposed contract: [`spec/package-layers.json`](../spec/package-layers.json).
- Edition/platform mapping: [`spec/editions.json`](../spec/editions.json).
- Current implemented `mac-intel` package delta: [`profiles/mac-intel/packages.x86_64`](../profiles/mac-intel/packages.x86_64).
- Existing staging script: [`scripts/prepare-profile.sh`](../scripts/prepare-profile.sh), which copies installed ArchISO releng and merges exact package names.
- Source-only validator: [`tests/test_package_layers.py`](../tests/test_package_layers.py).

## Order and dependencies

| Layer | Precedent | Runtime role | Current disposition |
| --- | --- | --- | --- |
| `arch-releng` | ArchISO official releng | signed upstream rescue/installer root, **never vendored by default** | External input, staged only during future build |
| `intel-hardware-overlay` | Nemesis manifest | Intel microcode, firmware packages and read-only diagnostics | Committed source, not a built image |
| `mac-desktop-kde` | EndeavourOS/Garuda edition separation | optional KDE/HiDPI/accessibility | Design only |
| `field-operator` | Garuda/CachyOS profile separation | optional RF/SDR/security and engineering packages | Design only |
| `t2-support` | t2linux research | separate T2 kernel and firmware policies | Research only |
| `asahi-platform` | Asahi project | ARM64 platform, boot chain and drivers | Research only |

The selected composition for the first candidate live ISO is `arch-releng → intel-hardware-overlay`. No desktop, operator, T2, or Asahi packages are selected by default. Research layers are **not interchangeable** with an Intel non-T2 image.

## Deterministic policy for a future resolver

1. Validate edition platform and allowed layer IDs; reject T2/ARM crossover.
2. Topologically order dependencies; use declared increasing `order` for stable tie-breaking. Reject missing layers, duplicate IDs, cycles or conflicting priorities.
3. Begin with upstream ArchISO package order, append a reviewed selected layer's additions, and deduplicate **exact package names**, retaining the first occurrence.
4. Fail closed on declared conflicts: require an explicit decision on why a conflicting package/driver is replaced; **do not resolve by silently removing or force-installing packages**.
5. Unknown overlaps with the **current installed upstream package list** can only be determined at actual profile staging; repository tests do not pretend the local Arch package snapshot is pinned.
6. Default signed official Arch package sources. AUR, third-party kernels and T2/Asahi driver sources require source, signature, license and safety review. No `TrustAll` or `SigLevel = Never` release bypass.
7. No auto-selection of Broadcom drivers from Mac model year, no proprietary Apple firmware extraction, no default remote credentials.
8. Do not automatically update the existing `prepare-profile.sh` to consume this specification. A separate implementation ADR and fixture/native-Arch tests are required before changing any build behavior.

## Verification

GitHub Actions runs:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

Tests validate composition safety, graph acyclicity, stable ordering, manifest existence, platform exclusions and exact active-layer selection. These are **source gates only**. They are not dependency resolution against the live Arch package databases and cannot certify bootability.

## Remaining questions for implementation

- How will package version snapshots, signatures, conflict metadata and mirrors be pinned per artifact?
- What policy will govern firmware licenses, proprietary drivers and DKMS on older Broadcom Macs?
- When and how should optional KDE and operator modules be installed after initial live/rescue acceptance?
- How will dependency conflicts be verified against the actual signed Arch package repositories without granting package installation authority to a repo-only Codex?

These are inputs for F03/F04 and, later, a separately approved image resolver—not permissions to execute today.

## Source-only acceptance evidence — 2026-11-19

[Commit 9105adc](https://github.com/pskeffington/nemesis/commit/9105adc5d62d6d3fac623822a3d5579166e2bda5) added the package policy and tests. [GitHub run 44608516336](https://github.com/pskeffington/nemesis/actions/runs/44608516336) passed 11 Python source tests; [static CI 44608516293](https://github.com/pskeffington/nemesis/actions/runs/44608516293) passed. F02 is accepted as a **declarative source-design gate only**: no live Arch dependency solver, image build, or hardware test. F04 owns future supply-chain approvals.

## MacBook Air optional field layer

`macbook-air-field-tools` depends on `intel-hardware-overlay` but is **not selected** in the existing `mac-intel` build. Its candidate package list (`bluez`, `bluez-utils`, `powertop`, `wireguard-tools`) comes from official Arch repositories; this source-only edition has no service auto-enable, Broadcom `wl`, TLP, fan controller or USB autosuspend override. An opt-in `scripts/prepare-air-field-profile.sh` stages this layer and `scripts/build-air-field-iso.sh` builds a separate `nemesis-air` image. The Docker gate is independently tracked by issue #15; the generic rescue build remains unchanged.

## Operator composition refinement — 2026-11-20

The independent `mac-intel-operator` edition is **now source-stageable**. The older description of `mac-desktop-kde` and `field-operator` as design-only applies to historical F02 before the Operator build branch; it does not describe the current source tree. Use [Operator literature and package matrix](research/OPERATOR_PACKAGE_LIT_MATRIX.md) and [kit contract](../spec/operator-kits.json) as the active source authorities.

The current Operator source composes `arch-releng → intel-hardware-overlay → macbook-air-field-tools → mac-desktop-kde → field-operator (core)`, then applies a separately reviewed **Operator-only inherited releng exclusion list** to reduce packages that are not needed for daily use. Rescue and Air remain unchanged. `profiles/mac-intel-operator/toolkits/` lists optional field and advanced packages that are copied as **text manifests** into Operator images but **not** passed to `mkarchiso` as package requests. No generalized layer resolver or installation mechanism is implied.

For a persistent installed computer, `nemesis-kit install KIT` requires authenticated root and refuses live-ISO use. The installer and installed-system security/boot configuration are **NOT IMPLEMENTED**. Check full pacman dependency graph and compressed ISO output, not package line count, for savings. [PR #21](https://github.com/pskeffington/nemesis/pull/21) introduces the controls; source/native Arch and Docker must be separately accepted.
