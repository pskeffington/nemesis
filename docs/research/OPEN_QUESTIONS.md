# Research questions and design-decision queue

| ID | Scope | Question | Current evidence | Owner agent | Decision / experiment | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Q-01 | x86_64 ISO | Does current packaged releng keep required 64-bit UEFI boot files after Nemesis overlay? | ARC-01..05 | archiso-build-engineer | Stage profile; ISO build; list EFI image and VM boot | READY |
| Q-02 | First Intel Mac | Which exact non-T2 Mac model is available for external-boot acceptance? | MAC-01..03 | intel-mac-compatibility | Confirm model ID without serial; plan USB/keyboard/recovery | BLOCKED on test hardware selection |
| Q-03 | Broadcom | Which PCI IDs and firmware files are needed on first device? | WIFI-01..02 | intel-mac-compatibility | Read-only ID probe then driver/firmware fit | BLOCKED on hardware ID |
| Q-04 | Old EFI | Which legacy/mixed 32-bit EFI models need special boot artifacts? | MAC-02; upstream boot docs | uefi-boot-validator | Research by model; test only after regular 64-bit UEFI | DEFERRED |
| Q-05 | Installer | Which graphical installer can safely preserve/recover macOS partitions? | SEC-01 | security-release-reviewer | Threat model, dry runs and rollback | DEFERRED |
| Q-06 | T2 image | Can T2 kernel/firmware deps be built with verified source provenance and package signatures? | T2-01..03 | t2-platform-engineer | Inspect upstream artifacts and package trust | DEFERRED |
| Q-07 | Apple Silicon | Which one ARM64 Mac/SoC is first feasible and what boot-policy/provisioning changes are necessary? | ARM-01..06 | asahi-platform-engineer | Model-specific upstream matrix and separate ADR | DEFERRED |
| Q-08 | Source reproducibility | How will input package versions and upstream profile revision be captured and release-locked? | ARC-01..05 | build-qa-engineer | Emit manifest, package lock evidence and provenance | READY |
| Q-09 | Hardware privacy | Can diagnostic logs be reduced to non-identifying IDs before contributing to compatibility table? | methodology | security-release-reviewer | Redaction review and a safe recording template | READY |

Additional recon issues: **Q-10 (upstream contract):** does installed releng on current signed ArchISO retain EFI/syslinux/grub semantics after Nemesis staging? Owner build-qa-engineer, next `tests/test-installed-releng.sh` in Arch CI. **Q-11 (release reproducibility):** which extra package/boot artifact manifests and signing chain are required beyond a portable ISO SHA-256? Owner security-release-reviewer; defer until M02.

Update the decision in docs/DECISIONS.md before turning a research idea into a build dependency. **No Q item is an accepted hardware result.**
