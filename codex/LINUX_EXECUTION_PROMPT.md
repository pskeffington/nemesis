# Codex future prompt — activate only after handoff GO

**INACTIVE TEMPLATE.** Do not use while `docs/FOUNDATION_PRIORITY_PLAN.md` indicates repository-only work.

After a human approves the phase change and `codex/HANDOFF_CONTRACT.md` is complete, start from a pinned GitHub commit on an explicitly approved **x86_64 Arch/Garuda build host**. Read `AGENTS.md`, `docs/RELEASE_GATES.md`, `docs/BUILD_AND_QA.md`, `codex/BUILD_RUNBOOK.md`, and the handoff packet.

1. Confirm actual host architecture, available space, network, tools and official package repositories. Fresh Garuda systems may lack all dependencies. Do not assume or silently install them.
2. Run source/static and native releng tests; record command outputs and any drift before requesting build privileges.
3. After explicit privilege approval, build the scoped `mac-intel` ISO and verify a **new** portable checksum; record source SHA, ArchISO/kernel/package versions.
4. Stop. A successful ISO build is **not** an authorization for UEFI virtual tests, USB writing or Mac installation.
5. Escalate failures with exact command/exit, private redacted logs, responsible role and rollback. Never weaken package signatures or reformat storage to pass a gate.

No T2/ARM auto-provisioning, no unattended root operations, no unredacted log push, no assumed user passwords or secrets. Source-only CI success cannot substitute for ISO, UEFI or Mac hardware acceptance.
