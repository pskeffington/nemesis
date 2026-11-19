# Mac hardware compatibility — evidence-based matrix

**No Nemesis ISO has been physically tested yet.** The next priority is Intel MacBook Air7,2 and 6,x; see [Air field research](research/MACBOOK_AIR_FIELD_MATRIX.md). The successful [Docker image assembly](https://github.com/pskeffington/nemesis/actions/runs/44610122687) is **not** device support proof. See [candidate Intel models](research/INTEL_MAC_CANDIDATES.md) for a source-only test prioritization, not a support certification. A proposed target is not a verified working machine. Do not publish 'supported' labels until model-specific acceptance results exist.

| Hardware family | CPU / boot | Nemesis build lane | Current claim | Verification |
| --- | --- | --- | --- | --- |
| Most non-T2 Intel Macs with 64-bit EFI | x86_64 / UEFI | mac-intel | Primary target | PENDING |
| Older Intel Macs with 32-bit or unusual EFI | x86_64 CPU may have mixed EFI | mac-intel research | Possible separate boot mode | PENDING |
| Intel Macs with Apple T2 | x86_64 / Apple T2 boot policies | mac-t2 | Separate patched-kernel study | PENDING |
| Apple Silicon Macs | ARM64 / Apple boot chain | mac-asahi | Independent architecture; **not bootable** with mac-intel image | OUT OF SCOPE |
| PowerPC Macs | PPC | none | Not supported | OUT OF SCOPE |

For orientation, Mac marketing years alone cannot reliably separate firmware, chips or drivers. Use the precise model identifier and actual device IDs.

## Physical acceptance checklist

Record one row per Mac model in a future results file (without serial numbers):
- Model identifier (e.g. output of `cat /sys/class/dmi/id/product_name`) and whether T2 is present.
- ISO filename/hash, kernel version, firmware/UEFI generation and test date.
- Boot picker detects USB via Option/Alt; kernel/live shell starts.
- Keyboard and trackpad functional, including external USB recovery input.
- Screen resolution, brightness and GPU rendering.
- Wi-Fi chipset/PCI ID, selected driver and functional networking; Bluetooth separately.
- Storage appears without write operations; NVMe/SATA and USB observed.
- Sound, microphones, camera, fan, temperatures, battery and suspend/resume separately graded.
- Recovery/return to macOS proven before any subsequent install trial.

Statuses for each device: `PASS`, `FAIL`, `PARTIAL`, `NOT TESTED`; link evidence rather than inventing it.

## Important device-specific cautions

- **Broadcom:** not all Broadcom devices use the same driver. T2 Linux specifically recommends `brcmfmac`, *not* `broadcom-wl`, for its supported T2 models. Other older Macs must be evaluated by chipset ID.
- **T2:** the stock releng ISO cannot be declared functional for internal keyboard/trackpad/audio. A dedicated image and firmware/driver validation gate is required.
- **Apple Silicon:** upstream Asahi has separate coverage by SoC and model. Fedora Asahi Remix 45 offers mature M1/M2 support and initial M3-family support; do not extrapolate to every M4/M5.
- **macOS safety:** apply available macOS firmware updates and back up the system before changing partitions; preserve recovery access. The live-ISO workflow never touches internal disk layouts.

References: https://wiki.archlinux.org/title/Mac ; https://wiki.t2linux.org/state/ ; https://wiki.t2linux.org/guides/wifi-bluetooth/ ; https://fedoramagazine.org/fedora-asahi-remix-45-is-now-available/
