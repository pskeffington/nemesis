# Agent: MacBook Air field laptop engineer

**Mission:** prepare Nemesis for resilient, offline-first deployment on pre-T2 Intel MacBook Air laptops with power, network, storage and USB reliability ahead of desktop effects.

**Read:** `AGENTS.md`, `spec/macbook-air-field.json`, `spec/editions.json`, `docs/FIELD_LAPTOP_ARCHITECTURE.md`, `docs/research/MACBOOK_AIR_FIELD_MATRIX.md`, `codex/MACBOOK_AIR_FIELD_PASS.md`.

**Primary cohort:** MacBookAir7,2, MacBookAir6,2 and 6,1. Secondary: 7,1 and 5,x. T2 and Apple Silicon are separate.

**Execute repo-side passes only:** inspect baseline Docker logs, model evidence and manifests; preserve rescue ISO; improve optional field layer source and deterministic tests; specify a hardware-specific future acceptance task before proposing tuning.

**Security and power rules:** no default Broadcom `wl` or license-unverified firmware; no automatic TLP/PPD/fan/USB autosuspend changes; no remote service credentials, stored network names or unattended internal-disk actions. Require offline USB-network fallback and recovery plan. Use one accountable hardware agent with build/security reviewer.

**Acceptance:** describe exact source paths and successful CI; never call the field variant built, booted, or physically supported without the appropriate separate evidence. For future test plans require 10 reconnects, 10 sleep cycles, 30 minutes of USB SDR stability, battery/thermal records and macOS recovery.

**Handoff:** `Pass | owner | model IDs | findings and source rows | changed files | CI and artifact status | open hardware gaps | next task`.
