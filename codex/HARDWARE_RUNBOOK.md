> **FUTURE EXECUTION / REFERENCE ONLY.** Nemesis is currently in GitHub-only repository foundation mode. Do not run Linux builds, VM boots or physical Mac procedures from this document until F05 handoff acceptance and explicit user GO. See [foundation priorities](../docs/FOUNDATION_PRIORITY_PLAN.md) and [handoff contract](HANDOFF_CONTRACT.md).

# Mac hardware acceptance runbook

Use this only after the preceding build and UEFI-VM gates pass.

## Intel non-T2 physical test
- Confirm exact model ID (no serial); 64-bit EFI vs legacy exception and lack of T2.
- Confirm current macOS backup and independently bootable recovery. Use an external keyboard, known-good USB medium and power supply.
- User selects and verifies removable media; flashing is intentionally not automated by this repository.
- Observe Option/Alt Startup Manager, bootloader, kernel and live shell.
- Run `nemesis-hw-report` and redact output before public use; record ISO hash and kernel.
- Test individually: display/GPU/brightness, keyboard/trackpad, Wi-Fi and Bluetooth, Ethernet/USB, sound and microphone, webcam, CPU temperatures/fans, battery and suspend.
- Mark each device PASS/FAIL/PARTIAL/NOT TESTED. Record exact PCI/USB ID and driver, not blanket Mac-year claims.
- Exit live environment; verify macOS and recovery still work. Do not mount or rewrite APFS volumes to “help” the test.

## Intel T2 (not authorized for normal Intel profile)
- Review the T2 state matrix, firmware license, external boot setting and signature choices.
- Stock Intel profile cannot be considered accepted for built-in T2 keyboard, audio or trackpad.
- T2 user-owned security changes, package provenance and physical observations require separate approval.

## Apple Silicon (research only)
- Follow Asahi model-specific feature tables and documented boot chain.
- An x86_64 ISO does not boot M-series Macs; purely external Linux boot without internal disk changes is not an available safety strategy.
- No provisioning, recoveryOS or disk alterations in this early lane.

See docs/MAC_COMPATIBILITY.md and docs/research/LITERATURE_MATRIX.md. Publish sanitized model-level findings only.
