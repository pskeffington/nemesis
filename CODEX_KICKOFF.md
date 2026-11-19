# Codex kickoff — Nemesis Mac-first Arch distribution

Use this at the start of a fresh Codex session on an x86_64 Arch/Garuda Linux development host.

## First workstation preparation

```bash
sudo pacman -Syu --needed git archiso shellcheck
git clone https://github.com/pskeffington/nemesis.git
cd nemesis
git status --short
cat AGENTS.md
cat ROADMAP.md
cat codex/SESSION_PROMPT.md
bash scripts/validate.sh
```

If the repository already exists: `cd nemesis && git pull --ff-only`; do not reclone or overwrite local changes. Reboot after a system upgrade when the kernel/packages require it, before beginning the ISO build.

**Codex launch:** run `codex` in the repository after the CLI is installed and authenticated. If an existing Linuxbrew install isn't on PATH, initialize Linuxbrew from its actual installed path first; do not assume all machines have the same location. Paste the exact [session prompt](codex/SESSION_PROMPT.md).

## Immediate assignment

**M01-P02:** run static/fixture validation and repair any profile/manifest defects. Then **M02-P01:** build the first Intel non-T2 ISO on the x86_64 host, produce a checksum and log, and document result without calling it boot-tested.

Proceed to **M03-P01** only when the ISO build gate passes. Do not run USB flashing, repartition, firmware updates, T2 installer actions or Apple Silicon provisioning without explicit hardware review and user-controlled device selection.

## Handoff contract

Read [pass queue](codex/PASS_QUEUE.md), [build runbook](codex/BUILD_RUNBOOK.md), [hardware runbook](codex/HARDWARE_RUNBOOK.md) and [agents](agents/README.md). After every pass, commit source/docs, link actual test evidence and update ROADMAP.md statuses. Never commit raw firmware, large ISO images, local machine secrets or identifying logs.
