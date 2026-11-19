# Research, provenance and compatibility-claim policy

## Evidence classes
- **S1:** upstream source, kernel-maintainer design, official vendor platform/boot documentation; cite exact URL, revision/version if possible.
- **S2:** ArchWiki, t2linux community guides, maintainer-authored compatibility grids; treat as implementation guidance and test model-specific results.
- **S3:** issue trackers, forums and individual reports; useful for hypotheses but cannot alone justify an unconditional release claim.

## Every literature-matrix update
1. State the technical question and relevant Mac family; identify model and chipset where possible.
2. Search S1 first, then S2. If a claim is contested, record both and prioritize a reversible test.
3. Add or revise a stable row ID in LITERATURE_MATRIX.md, source ID, source type, finding, actionable decision and acceptance gate.
4. Record the read/review date. Distinguish “current when read” from “published on date.” Do not invent a source version.
5. Mark source-backed knowledge as **SOURCE CHECKED**, never **NEMESIS PASS** until direct evidence exists.
6. Link exact fixture log, build hash, virtual boot log or model-level test outcome. Redact serials, MAC addresses, owner data and location before publication.
7. If upstream behavior changes, revise decisions/ADR and affected scripts, then re-run acceptance. Prefer official signed packages by default.

## Physical experiment template
- Purpose; Mac model identifier; whether T2 is present; kernel/firmware version; ISO source commit and SHA-256.
- Pre-conditions: backup verified, return-to-macOS route, known-good external keyboard/USB and power.
- Procedure: external boot only, read-only inventory, display/input/network tests, thermal/suspend tests when safe.
- Observations per feature: PASS / FAIL / PARTIAL / NOT TESTED; command and log ID.
- Safety: no internal partition writes, no secure-boot policy modifications, no firmware extraction.
- Conclusion: acceptance gate decided by observed hardware, not by driver-module presence alone.

## Source correction practice
If documentation conflicts (e.g. Intel Broadcom driver advice vs. T2-specific instructions), record the exact scope instead of averaging the two. Put unresolved conflicts in OPEN_QUESTIONS.md and block the affected release lane until model-level evidence resolves them.

## Publication
Research notes are public by default. Never publish full `dmesg` logs, Wi-Fi network names, keys, hardware serials, captures or Apple firmware dumps unless explicitly sanitized; keep raw artifacts local.
