# Nemesis Codex session prompt — current phase

**MODE: REPO_FOUNDATION.** Read `codex/REPOSITORY_PHASE_PROMPT.md` and follow it as the authoritative Codex prompt for current work.

We are building the distro **in GitHub and disposable GitHub Actions Docker only**. Do not start or change a user's Garuda/Linux, Mac, USB, firmware or partitions; QEMU/physical boot remains deferred. Signed Arch packages and privileged `mkarchiso` are permitted only inside the approved disposable Docker CI, never on a local workstation.

Current priority: **Nemesis Operator OP-01/OP-02**. Read `docs/OPERATOR_EDITION.md`, `spec/operator-edition.json`, `codex/OPERATOR_PASS.md`, and the [Operator issue #19](https://github.com/pskeffington/nemesis/issues/19). Source/static/native ArchISO gates passed on `main` commit `e36930c`; Rust renderer compiled as non-root in [Docker run 44734587874](https://github.com/pskeffington/nemesis/actions/runs/44734587874). Verify remaining ISO and built SquashFS gates from actual job evidence, repair failures, then report the built Operator artifact without asserting KDE runtime or MacBook Air compatibility. F03 hardware, F04 release and F05 local-machine handoff remain separate NO-GO gates.

Maintain one pass/owner at a time, protect existing branches/brand PR #5, cite source evidence, make minimal reversible edits, verify repo source CI, and update `ROADMAP.md` with actual statuses. No physical claims or fake acceptance.
