> **FUTURE EXECUTION / REFERENCE ONLY.** Nemesis is currently in GitHub-only repository foundation mode. Do not run Linux builds, VM boots or physical Mac procedures from this document until F05 handoff acceptance and explicit user GO. See [foundation priorities](FOUNDATION_PRIORITY_PLAN.md) and [handoff contract](../codex/HANDOFF_CONTRACT.md).

# Nemesis release engineering gates

These are cumulative checkpoints, not a checklist that can be marked complete from a GitHub commit alone.

| Gate | Owner | Required artifact | Acceptance |
| --- | --- | --- | --- |
| G0 — source | build-qa-engineer | revision + static test output | Bash syntax, ShellCheck and package/fixture checks pass |
| G1 — ISO assembly | archiso-build-engineer | build log, package/provenance versions, ISO hash | real `mkarchiso` exit 0 and portable checksum validates |
| G2 — virtual UEFI | uefi-boot-validator | OVMF/QEMU log | bootloader -> kernel -> live shell; diagnostics callable |
| G3 — Intel Mac hardware | intel-mac-compatibility | one or more model/feature sheets | physical external boot, essential I/O and macOS return proven |
| G4 — install/desktop | distro-architect | approved installer/recovery design and test results | installed environment, user-facing hardware and rollback validated |
| G5 — release safety | security-release-reviewer | license, firmware, package-signing, privacy and regression review | all critical safety/security issues closed and approval recorded |

T2 and Apple Silicon have **separate G2–G5 adaptations** that cannot be inherited from Intel Mac acceptance. Source matrix updates are supporting evidence, never a substitute for tests.

## Minimum evidence manifest
```text
nemesis_commit:
pass_id:
host_architecture:
host_os:
archiso_version:
kernel_version:
upstream_profile_version_or_package:
build_command:
build_exit_code:
iso_filename:
sha256:
checksum_verified_from_output_dir:
ovmf_firmware_version:
virtual_boot_result:
mac_model_identifier_without_serial:
physical_boot_result:
device_feature_results:
macos_recovery_verified:
reviewer:
decision: NOT STARTED | IN PROGRESS | BLOCKED | REVIEW | ACCEPTED
```

Keep raw logs off Git; commit only sanitized summaries and small manifest files. A released ISO must also include a traceable source/manifest and third-party license audit.
