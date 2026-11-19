# Contributing to Nemesis

Start with AGENTS.md, CODEX_KICKOFF.md, ROADMAP.md and docs/research/LITERATURE_MATRIX.md.

1. Choose one pass from codex/PASS_QUEUE.md and identify the responsible agent in agents/README.md.
2. Keep changes small, reversible and limited to the active hardware lane; add sources for claims and tests for scripts.
3. Run `bash scripts/validate.sh` before proposing merges. ShellCheck is mandatory for a fully accepted static gate.
4. For ISO claims, record real mkarchiso exit code, exact ISO SHA-256 and package versions; for Mac claims, provide redacted physical results.
5. Distinguish SOURCE CHECKED, IMPLEMENTED, STATIC TESTED, BUILT, VM BOOTED and PHYSICALLY TESTED.
6. Do not commit binary ISOs, build worktrees, firmware, full logs, sensitive device IDs, secrets or personal information.
7. Do not introduce unsigned release repositories or internal disk/firmware mutation workflows by default; request a specific design/security review first.
8. Update ROADMAP.md and docs/DECISIONS.md if technical scope or acceptance changes.

Source and docs can be committed without a physical Mac; do not mark hardware gates complete until observed.
