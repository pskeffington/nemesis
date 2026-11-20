# Nemesis Codex pass queue — repo phase first

**Authority:** `docs/FOUNDATION_PRIORITY_PLAN.md`; current mode `REPO_FOUNDATION`. Changes are authored and verified in GitHub only until F05 plus explicit user GO. Use root `AGENTS.md` for safety and reporting.

| Order | ID | Accountable role | Concrete deliverable | Acceptance | Status |
| --- | --- | --- | --- | --- | --- |
| 0 | F00 | distro-architect | verified source, upstream recon and baseline decisions | source-pinned research and prior CI | ACCEPTED |
| 1 | F01 | distro-architect | edition/platform schema `spec/editions.json` and tests | GitHub run 44608135155 | ACCEPTED |
| 2 | F02 | archiso-build-engineer | module/manifest DAG, precedence, conflicts, signing policy | 11 source tests in CI 44608516336 | ACCEPTED (source design) |
| 2b | F02-V01 | archiso-build-engineer | GitHub Docker full ISO build evidence, checksum, El Torito UEFI report | trusted container ISO build (not virtual boot) | IN PROGRESS, [#12](https://github.com/pskeffington/nemesis/issues/12) |
| 2c | F03-A01 | macbook-air-field-engineer | Air optional field source, readonly diagnostic, six-model acceptance schema | [foundation/static CI 44612120052/50](https://github.com/pskeffington/nemesis/actions/runs/44612120052) | ACCEPTED (source only) |
| 2d | OP-01 | operator-desktop-engineer | pinned live wallpaper, KDE autostart, offline indicator and signed operator tools | source/fixture/Arch-stage CI | SOURCE COMMITTED / CI REVIEW, PR #18 |
| 2e | OP-02 | archiso-build-engineer | non-root Rust build, signed packages, Operator ISO and built SquashFS | GitHub Docker evidence, no boot claim | NOT YET ACCEPTED |
| 2f | R29-03 | operator-desktop-engineer | on-demand offline GeoJSON viewer and private notebook; operator-only files | Python data/privacy tests, signed ArchISO staging and later SquashFS | SOURCE COMMITTED — CI REVIEW; browser/Mac NOT TESTED |
| 3 | F03 | intel-mac-compatibility | model/feature evidence, device ID, firmware/boot contract | source-backed matrix, no unobserved hardware PASS | READY — NEXT |
| 4 | F04 | security-release-reviewer | package/ISO provenance, release criteria and recovery plan | review gates and no insecure trust bypass | NOT STARTED |
| 5 | F05 | build-qa-engineer | pinned `codex/HANDOFF_CONTRACT.md` packet | F02–F04 accepted + explicit human GO | NOT STARTED |
| optional | F06 | separate visual design role | icon/KDE/wallpaper source and reversibility | branch PR #5, nonblocking; physical test deferred | PARALLEL |
| hold | M02-P01 | archiso-build-engineer | actual Intel ISO and SHA | authorized Linux build with real evidence | DEFERRED |
| hold | M03-P01 | uefi-boot-validator | actual UEFI VM boot | accepted M02 | DEFERRED |
| hold | M04-P01 | intel-mac-compatibility | actual Mac model-level tests/recovery | accepted M03 + approved device | DEFERRED |

## F02 — accepted repo-only source contract

1. Read `spec/editions.json`, official ArchISO package list, existing baseline manifest, UP-01..UP-08 source decisions.
2. Define package layer order/selection, dependencies, conflicts, provenance and optional edition exclusion rules.
3. Write a separate machine-readable proposal and deterministic static test; never silently wire it into the real image builder in this pass.
4. **Observed:** 11 Python source tests PASS in CI 44608516336, static workflow 44608516293 PASS.
5. **Accepted scope:** declarative source policy, not live package resolution or a built ISO. Next F03, never M02.

## F03 — hardware policy

1. Map feature test vocabulary and Mac model identifiers, GPU/input/network/audio/thermal/sleep priorities.
2. Declare candidate/source-only vs actually observed support; include kernel/firmware rights/PCI ID and fallback.
3. Keep T2 and Asahi independent and require explicit installer/recovery decisions.
4. Add source-only schema/tests and review by security.

## F04 — release/supply chain

1. Specify package trust, traceable package/version manifest, ISO hash/signing, software bill of materials, recovery and update policy.
2. Separate requirements for source CI, actual ISO build, UEFI VM and real Mac.
3. Record hard release blockers; do not set public release-ready from documentation.

## F05 — handoff decision

Complete the `codex/HANDOFF_CONTRACT.md` fields from observed evidence, pin source/CI, specify allowed first command and root permissions, and obtain explicit authorization. **Do not schedule, initiate or imply Linux execution from the presence of a prompt.**

## Historical accepted passes and deferred execution

- M01-P02: Bash/ShellCheck/manifest/fixture validation — accepted from GitHub CI.
- M01-P03: source-pinned distro upstream recon — accepted as research.
- M01-P04: native ArchISO 92-1 profile staging — accepted [CI 44607322858](https://github.com/pskeffington/nemesis/actions/runs/44607322858), but no ISO built.
- M02-P01: [issue #2](https://github.com/pskeffington/nemesis/issues/2), parked. Future commands live in `codex/BUILD_RUNBOOK.md`.
- M03-P01: [issue #3](https://github.com/pskeffington/nemesis/issues/3), parked UEFI validation.
- M04-P01: [issue #4](https://github.com/pskeffington/nemesis/issues/4), parked Mac test; no internal disk changes.

**All pass reports:** ID | source revision | owner | paths | exact GitHub checks and result | remaining review | accepted/blocked decision | next repo-side task. Never infer tests that did not run.
