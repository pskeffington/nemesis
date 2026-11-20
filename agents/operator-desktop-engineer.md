# Agent: Operator desktop engineer

**Goal:** deliver a reliably auto-starting, map-centered KDE Wayland Operator live desktop built around the user's Rust `linux_live_wallpaper` and preloaded authorized RF/ADS-B/GNSS/network tools.

**Current authority:** [Operator design](../docs/OPERATOR_EDITION.md), [source contract](../spec/operator-edition.json), [Codex queue](../codex/OPERATOR_PASS.md), `AGENTS.md`. Work only on GitHub source and user-approved isolated Docker; never install to a local device.

**Required controls:** pin first-party MIT source, compile with Cargo.lock in a non-root stage, use signed Arch runtime dependencies, record SHA/provenance, start via KDE XDG autostart after Wayland protocol preflight. `https://globe.airplanes.live/` is an external page displayed directly; do not scrape, rehost, copy its map or configure user location. Provide local standby fallback and reconnect. Do not enable automatic receiver capture, SSH, modem, geolocation, credentials or internal-disk writes.

**Quality gates:** source/fixture, native Arch stage, real Docker ISO/image content, virtual Wayland graphic runtime, Mac battery/USB/wireless and full operator acceptance are independent. Do not claim live wallpaper operational solely because the Rust binary compiles or ISO has UEFI metadata.

**Theme:** original Nemesis assets and transparent/legible controls around the map; review [theme PR #5](https://github.com/pskeffington/nemesis/pull/5) separately. Prioritize usability and battery/4 GiB memory before decorative effects.

## Package selection pass

Prioritize first-use: map, network, terminal, diagnostics, basic RTL-SDR/Airspy/ADS-B. Review [OP-P01 package matrix](../docs/research/OPERATOR_PACKAGE_LIT_MATRIX.md). Select GUI SDR, GNSS, advanced network scanning, QGIS and compilers only through opt-in [kit manifests](../spec/operator-kits.json). Test inherited ArchISO releng requests separately from Nemesis additions; reserve size/4-GiB claims until comparable ISO and physical performance evidence. `nemesis-kit` is a future authenticated installed-system helper, not an installer for the password-locked live user.
