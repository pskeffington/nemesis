# Nemesis Mac/Linux engineering literature matrix

**Review date:** 2026-11-19. **Scope:** Mac-first distro architecture, hardware and first ArchISO acceptance. This is a maintained *technical source matrix*, not a claim that Nemesis hardware was tested.

## Evidence policy

- **S1 — Primary upstream or vendor technical documentation:** source design and platform contracts. **S2 — ArchWiki and community-maintained distribution guidance:** useful for model-specific diagnosis; verify on physical hardware. **S3 — Individual reports/forums:** hypotheses only.
- **SOURCE CHECKED** means the linked source supported the summarized statement at review. It does **not** mean the Nemesis change was compiled, booted or tested. **NEMESIS GATE PENDING** means implementation or physical acceptance remains open.
- Record source revision/date when available; the visit date is *not* a publication date. Hardware changes and rolling-release regressions require fresh verification before a release.
- Evidence sequence: source checked -> requirement documented -> implementation built -> VM booted -> actual Mac booted -> observed peripheral checks -> accepted. Never skip a tier.

**Comparable distro repositories:** [source-pinned recon and adoption decisions](UPSTREAM_DISTRO_RECON.md) (UP-01..UP-08). These supplement source rows ARC/ARM/T2 and do not add hardware pass claims.

## Evidence-to-decision matrix

| ID | Topic | Source/tier | Source-backed finding | Nemesis decision | Next observable gate |
| --- | --- | --- | --- | --- | --- |
| ARC-01 | Build substrate | [S01] S2; [S02] S1 | ArchISO supports configurable live media; packaged releng is an install/rescue starting point. | Copy *installed* releng; keep Nemesis as package delta and overlay. | Run on real Arch/Garuda x86_64; record archiso version and checksum. |
| ARC-02 | Profile schema | [S03] S1 | The profile supplies `profiledef.sh`, `packages.x86_64`, `airootfs` and permissions; ISO naming derives from profile fields. | Validate releng field presence, preserve upstream boot entries and overlay file mode. | Stage fixture and installed releng; compare and inspect. |
| ARC-03 | Build invocation | [S04] S1 | `mkarchiso` accepts work/output directories and a profile; full build needs Arch tooling. | Keep source validation separate from actual ISO execution; do not claim a built ISO from lint. | Arch host build exits zero with exactly one new ISO and a checked SHA-256. |
| ARC-04 | Upstream profile drift | [S05] S1 | Current upstream releng includes Intel microcode, Linux firmware, iwd and common rescue utilities. | Deduplicate additions rather than maintaining a full static fork; reconcile each new archiso release. | Diff staged manifest and boot configuration against local upstream. |
| MAC-01 | Intel firmware | [S06] S2 | Arch installation media supports Intel Macs, not PowerPC or Apple Silicon; Mac setup needs device-specific steps. | Make non-T2 64-bit Intel Mac the first supported *target*, not an already-supported product. | External EFI boot and return to macOS on a recorded model. |
| MAC-02 | EFI boot paths | [S06] S2 | Mac Startup Manager commonly finds removable EFI boot entries; older/mixed EFI cases vary. | Retain upstream EFI boot path; research 32-bit EFI separately. | Observe Apple Option boot picker on each model. |
| MAC-03 | Model variation | [S07] S2 | Community hardware table records model-specific wireless, audio, input and suspend differences. | Record model ID, PCI/USB identifiers, version and feature-level PASS/FAIL; no marketing-year blanket claims. | Publish redacted physical test sheet, not speculative support stars. |
| WIFI-01 | Broadcom selection | [S08] S2; [S09] S1 | `brcmfmac`, `brcmsmac`, `b43` and `broadcom-wl` are not interchangeable; chipset/PCI ID is the starting point. | Do not preinstall `broadcom-wl` everywhere; discover device ID before driver policy. | Test wireless on hardware, record ID, firmware/driver/kernel and throughput/connectivity. |
| WIFI-02 | T2 wireless exception | [S10] S2 | T2 guidance uses in-kernel `brcmfmac` rather than `broadcom-wl`; some devices need macOS-derived firmware and iwd workaround. | T2 Wi-Fi remains separate from the non-T2 baseline; no copyrighted firmware blobs in repo or ISO. | Confirm firmware provenance and real T2 interface operation before enabling. |
| T2-01 | Device support | [S11] S2 | T2 devices have varying upstream coverage; input, audio, camera, suspend and some graphics need additional work. | Keep `mac-t2` a separate research lane and candidate image. | Identify reviewed kernel/driver set and test keyboard, trackpad, audio, thermals, suspend. |
| T2-02 | Firmware/security | [S12] S1; [S13] S2 | Apple T2 controls external-media boot policy; distro procedures require user-controlled pre-installation decisions. | Do not silently change Startup Security settings or partition macOS. | User-approved recovery/boot-policy checklist on physical T2 Mac. |
| T2-03 | Repository trust | [S13] S2 | A published T2 Arch guide contains a repo example with `SigLevel = Never`. | Treat that example as **not acceptable** for a Nemesis release; require verified package trust or documented exception reviewed by security. | Provenance and package-signing decision recorded before external repo use. |
| ARM-01 | Different architecture | [S14] S1 | Asahi documents a distinct Apple Silicon platform and boot architecture. | Apple Silicon is a separate ARM64 project lane; x86_64 ArchISO does not boot M-series Macs. | Boot-chain ADR and scoped supported-device target, not a renamed ISO. |
| ARM-02 | Boot chain | [S15] S1 | Asahi boot handoff includes Apple boot chain, m1n1, U-Boot, GRUB and Linux; initial stages use internal storage and machine policy. | No “USB-only, disk untouched” promise for Apple Silicon. | Independent boot and internal-storage safety design with rollback review. |
| ARM-03 | External media | [S16] S1 | Asahi FAQ states purely external boot with zero internal storage change is not possible on Apple Silicon. | Keep first non-destructive external-boot promise limited to applicable Intel Macs. | Document consented provisioning and recovery before any ARM install prototype. |
| ARM-04 | Feature matrix M1 | [S17] S1 | Feature support is per feature/model, including limitations in audio, camera and Touch ID. | Build device-level ARM matrix, not one “M1 works” label. | Supported model and each required peripheral verified. |
| ARM-05 | Feature matrix M2 | [S18] S1 | Support and upstreaming vary across base M2, Pro/Max/Ultra and Mac Pro. | No general release promise for every M2 Mac. | Compatibility sheet matched to exact SoC and Mac model. |
| ARM-06 | Feature matrix M3+ | [S19] S1; [S20] S1 | Asahi publishes separate generation-specific progress tables; “WIP” is not release-ready. | Gate M3/M4/M5 and later hardware by actual upstream support and observed results. | Review current generation pages before selecting target hardware. |
| SEC-01 | Release safety | [S06] S2; [S12] S1; [S16] S1 | EFI, partitions, boot policy and firmware can affect recovery differently by Mac generation. | Explicit backups, external-input recovery and no auto disk writes for initial test; ARM separate. | Signed-off recovery procedure and no unexpected writes observed. |

**Source status on 2026-11-19:** ARC-01..SEC-01 were reviewed against listed online documentation; *all Nemesis build, VM and physical gates remain unverified here*. The matrix is intentionally not a compatibility certification.

## Source registry

- **S01:** ArchWiki, *archiso* — https://wiki.archlinux.org/title/archiso
- **S02:** Arch Linux, *archiso project* — https://github.com/archlinux/archiso
- **S03:** Arch Linux, *archiso profile documentation* — https://github.com/archlinux/archiso/blob/master/docs/README.profile.rst
- **S04:** Arch Linux, *mkarchiso(1)* — https://man.archlinux.org/man/mkarchiso.1.en
- **S05:** Arch Linux, *releng package baseline* — https://github.com/archlinux/archiso/blob/master/configs/releng/packages.x86_64
- **S06:** ArchWiki, *Mac* — https://wiki.archlinux.org/title/Mac
- **S07:** ArchWiki, *Laptop/Apple* — https://wiki.archlinux.org/title/Laptop/Apple
- **S08:** ArchWiki, *Broadcom wireless* — https://wiki.archlinux.org/title/Broadcom_wireless
- **S09:** Linux Wireless project, *brcm80211* — https://wireless.docs.kernel.org/en/latest/en/users/drivers/brcm80211.html
- **S10:** t2linux wiki, *Wi-Fi and Bluetooth* — https://wiki.t2linux.org/guides/wifi-bluetooth/
- **S11:** t2linux wiki, *Feature state* — https://wiki.t2linux.org/state/
- **S12:** Apple Support, *Startup Security Utility and external media on T2* — https://support.apple.com/en-la/102522
- **S13:** t2linux wiki, *Arch installation* — https://wiki.t2linux.org/distributions/arch/installation/
- **S14:** Asahi Linux, *platform documentation* — https://asahilinux.org/docs/
- **S15:** Asahi Linux, *boot process* — https://asahilinux.org/docs/alt/boot-process-guide/
- **S16:** Asahi Linux, *FAQ / external storage boot* — https://asahilinux.org/docs/project/faq/
- **S17:** Asahi Linux, *M1 support* — https://asahilinux.org/docs/platform/feature-support/m1/
- **S18:** Asahi Linux, *M2 support* — https://asahilinux.org/docs/platform/feature-support/m2/
- **S19:** Asahi Linux, *M3 support* — https://asahilinux.org/docs/platform/feature-support/m3/
- **S20:** Asahi Linux, *feature-support generations index* — https://asahilinux.org/docs/platform/feature-support/overview/

## Cross-source findings requiring explicit decisions

1. **Arch official vs. Mac differences:** upstream ArchISO may boot Intel Macs, but the distribution still needs observed audio, touchpad, networking and suspend acceptance. A successful QEMU boot does not qualify a physical Mac.
2. **Broadcom driver mismatch:** the T2 rule for `brcmfmac` must not be blindly applied to all older Intel Macs; choose by PCI ID and upstream supported-device tables.
3. **T2 package trust:** a community installation guide is a useful reference, not authorization to disable repository signature verification in Nemesis.
4. **ARM external boot:** the Intel “test external USB without touching internal storage” acceptance concept is explicitly **not** portable to Apple Silicon.
5. **Release freshness:** archive all linked source revisions and build/package versions in release evidence when a particular version is chosen; this matrix's visited URLs are mutable.

Next review: whenever upgrading archiso/kernel, selecting a new Mac test model, considering a third-party kernel, or preparing an ISO release; also recheck any listed link that becomes unreachable. See [research methodology](METHODOLOGY.md) and [open decisions](OPEN_QUESTIONS.md).
