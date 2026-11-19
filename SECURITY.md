# Nemesis security and responsible contribution

The repository contains experimental operating-system source and build scripts. No general-purpose Nemesis release is currently approved.

## Boundaries
- All ISO assembly runs with elevated privileges on a **trusted** x86_64 Arch-family build host. Inspect scripts and Git changes before sudo.
- Never flash a guessed disk device or automatically change Apple T2 Startup Security Utility, EFI firmware, APFS volumes or Mac partitions.
- No unsigned package feeds (`SigLevel = Never`), default remote-login credentials, bundled proprietary firmware or unauthorized Apple redistributables in release profiles.
- Research and logs must be sanitized before publication; omit serials, MAC addresses, local network names, credentials, private keys, personal details and raw captures.
- A model is not “supported” because a forum post, driver module, QEMU or a successful ISO build says so.

For security defects, avoid publishing exploitation steps or secret material in a public issue. Coordinate privately with the repository owner using GitHub's security reporting mechanism if available. Submit source, acceptance evidence and a specific remediation proposal.
