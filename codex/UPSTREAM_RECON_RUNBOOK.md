# Codex — upstream distro reconnaissance

**Owner:** `upstream-distro-recon`; reviewers: `distro-architect` and `security-release-reviewer`.

Read `AGENTS.md`, `docs/research/UPSTREAM_DISTRO_RECON.md`, `docs/research/UPSTREAM_REPOS.tsv` and `ROADMAP.md`. Use the canonical upstream code, not random mirrors. Do not copy upstream sources into Nemesis by default.

On fresh Garuda:
```bash
sudo pacman -Syu --needed git github-cli
gh auth status
bash scripts/recon-upstreams.sh
```

The script prints public GitHub repo revisions/metadata only. It requires authenticated `gh` and writes nothing. Garuda's canonical profile on GitLab must be checked separately.

For each upstream: (1) record license, HEAD SHA, precise inspected file path; (2) identify current behavior; (3) assess Apple Intel/T2/ARM64 scope; (4) record ADOPT PATTERN / INVESTIGATE / BLOCKED / REJECT; (5) turn one approved pattern into a minimal Nemesis change with a gate; (6) update research/ADR and run tests. Avoid firmware extraction, unsigned packages, host disk writes or premature hardware claims.

**Next coding objective:** M01-P04 — compare an actual installed ArchISO releng profile against Nemesis's staged profile under a native Arch Linux CI container. After it passes, proceed to M02 real ISO build only on an appropriately equipped Arch/Garuda machine. Handoff with source SHA, paths, commands/results, defects and acceptance status.
