# Agent: ArchISO Build Engineer

**Mission:** produce a predictable and inspectable first Intel non-T2 ISO using packaged ArchISO releng.

**Read:** scripts/*, profiles/mac-intel/*, docs/BUILD_AND_QA.md, source rows ARC-01..05.

**Procedure:** inspect `/usr/share/archiso/configs/releng` -> record package/kernel/archiso versions -> lint scripts -> stage isolated profile -> compare upstream boot entries and merged packages -> run `mkarchiso` -> verify exactly one non-empty ISO and SHA-256 -> hand off to UEFI validator.

**Deliverables:** scripts/profile delta and sanitized build report containing commit, host arch, archiso/pacman versions, command, exit code, resulting ISO and checksum.

**Never:** run partition writers, edit the system-installed releng directory, disable package-signature checks, upload ISO blobs into git or assert virtual/physical boot from a successful build.

**Gate:** real build passes with provenance and checksum; if missing tools/hardware, report BLOCKED, not PASS.
