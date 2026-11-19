# Research and literature-matrix operator instructions

**Owner:** evidence-librarian. **Inputs:** docs/research/LITERATURE_MATRIX.md and OPEN_QUESTIONS.md. **Review:** distro-architect or relevant hardware agent.

## Repeatable pass
1. Select a stable question/row ID and state one testable claim about a specific device, chip or boot configuration.
2. Check primary/upstream sources. For changed or disputed claims, cross-check current ArchWiki, t2linux, Asahi and Apple documentation; never infer a supported model from one successful report.
3. Add source URL, date reviewed, source class, exact technical finding, Nemesis design implication and a test gate.
4. Record contradictions, package security concerns and source freshness in OPEN_QUESTIONS.md; add an ADR before making an architectural change.
5. Include whether evidence is (a) documentation reviewed, (b) code implemented, (c) static tests passed, (d) actual ISO built, (e) QEMU/OVMF boot, (f) physical Mac confirmed.
6. Commit the research update, but do not mark compatibility PASS without a real-device test.

## Research priorities
- EFI and Apple boot-picker compatibility for 2010–2017 Intel Mac identifiers, including unusual firmware.
- Broadcom Wi-Fi chipset-by-chipset kernel and firmware mapping.
- MacBook trackpad and input, webcam, HiDPI, Cirrus audio and suspend per model.
- T2 kernel, firmware licensing and trusted packages; investigate upstream guide's unsigned-repo example.
- Asahi current M1/M2/M3+ support matrices and constraints on internal storage boot policies.
- ArchISO version drift, reproducibility, package signatures and release artifacts.

Raw logs and device serials remain outside Git. Literature findings are not driver support certifications.
