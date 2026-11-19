# Intel Mac candidate test matrix — research, not compatibility certification

**Last reviewed:** 2026-11-19. **Evidence class:** ArchWiki community model reports (S2). No Mac listed below has been booted with Nemesis. This document identifies high-value validation candidates; the first test device depends on real hardware availability and safe external-boot access.

## Prioritized non-T2 candidate families

| Candidate model | Reason for testing | Upstream/community note to verify | Specific Nemesis gate | Status |
| --- | --- | --- | --- | --- |
| MacBookPro9,x (2012) | Practical early 64-bit EFI baseline | Laptop/Apple reports many tested core functions; requires confirmation for precise subtype | EFI media, graphics, internal input, network, audio, suspend | SOURCE ONLY |
| MacBookAir5,2 (mid-2012) | Thin Mac power/trackpad and wireless baseline | ArchWiki reports Broadcom wireless can require `broadcom-wl` for full-speed use | Record PCI ID; compare in-kernel driver and candidate firmware before considering proprietary DKMS | SOURCE ONLY |
| MacBookPro11,1 (late-2013) | Retina/HiDPI and camera decision | ArchWiki notes camera may need out-of-tree `facetimehd-dkms` | Display scale, keyboard, Wi-Fi, camera marked NOT TESTED until observed; no AUR default | SOURCE ONLY |
| MacBookPro12,1 (2015) | Later Broadcom chipset and Retina laptop | ArchWiki points to BCM43602 driver-specific issues | Actual chipset ID, `brcmfmac` operation, audio, suspend and brightness | SOURCE ONLY |
| MacBookPro8,1 (early-2011) | Older Mac longevity and driver fallback | ArchWiki notes `broadcom-wl` for full-speed Wi-Fi | EFI, older graphics, trackpad, thermal and Wi-Fi device-ID evidence | SOURCE ONLY |
| MacBookPro14,1 (mid-2017) | Modern pre-T2 challenges | Community record notes built-in audio may require an external driver and suspend issues | Distinguish functional boot from full daily-use status, audio and wake/recovery | SOURCE ONLY |
| MacBookPro14,2 (2017) | Touch Bar and distinct input/audio stack | Community record notes Touch Bar extra support and no Touch ID; audio/5GHz/suspend require attention | Test Touch Bar separately; do not promise fingerprint unlock | SOURCE ONLY |

**Separate comparison groups (not first ISO targets):** MacBookPro16,1 (2019) is a documented T2 example requiring a T2-specific kernel; M1/M2/M3-family Macs require the Asahi ARM64 boot stack. Neither belongs in the non-T2 pass/fail denominator.

## Method for selecting the first Mac

1. Inventory available candidate model identifiers without serial numbers. Confirm no T2 chip and a viable 64-bit external EFI boot path.
2. Prefer a model with accessible backup/recovery, physical keyboard fallback and known-good removable media over a theoretically more representative model.
3. Compare the reported GPU, wireless PCI IDs, camera, trackpad and audio against latest upstream documentation before packaging a driver.
4. Run the documented **read-only** test process from [MAC_TEST_REPORT_TEMPLATE.md](MAC_TEST_REPORT_TEMPLATE.md). Never modify internal disks or install drivers merely to complete initial boot acceptance.
5. Update docs/MAC_COMPATIBILITY.md and link sanitized actual evidence, then determine the next model to cover an untested chipset or boot path.

## Source references and caveats

- S07 [ArchWiki Laptop/Apple hardware report matrix](https://wiki.archlinux.org/title/Laptop/Apple); community rows vary in report date and completeness, and a reported “Yes” does not certify our ISO.
- S06 [ArchWiki Mac installation](https://wiki.archlinux.org/title/Mac); standard Intel EFI flow is not proof that every older model boots.
- S08 [ArchWiki Broadcom wireless](https://wiki.archlinux.org/title/Broadcom_wireless); PCI ID and kernel support determine drivers.
- S11 [t2linux feature support](https://wiki.t2linux.org/state/); T2 is a separate lane.

The matrix must be revised whenever selecting a specific physical Mac. Do not convert these candidate rows to PASS without physical test logs.
