# Build and verification — Mac Intel edition

## Prerequisites

An updated **x86_64 Arch Linux or Garuda Linux host** with Internet access, working sudo, free build space and `archiso`. The live image is not built natively on macOS. Use an Arch/Garuda host or a compatible x86_64 VM with adequate disk and RAM.

```bash
sudo pacman -Syu --needed git archiso shellcheck
git clone https://github.com/pskeffington/nemesis.git
cd nemesis
bash scripts/validate.sh
sudo bash scripts/build-iso.sh mac-intel
```

No package installation occurs inside the build script itself. Check the generated `out/mac-intel/` directory for the `nemesis-*.iso` artifact and matching `.sha256` file. Verify using:

```bash
cd out/mac-intel
sha256sum -c *.iso.sha256
```

Before rebuilding, inspect `.build/profile-mac-intel` and `.build/work-mac-intel`. The builder will refuse to overwrite them; remove them manually **only when no build is running** and after verifying that they are disposable generated directories.

## Acceptance ladder

| Check | Command / method | Required evidence |
| --- | --- | --- |
| Source validation | `bash scripts/validate.sh` | `bash -n`; ShellCheck when installed |
| Profile staging | `scripts/prepare-profile.sh mac-intel ABSOLUTE_PATH` | ArchISO profile with Nemesis name/label, packages and overlay |
| ISO execution | `sudo bash scripts/build-iso.sh mac-intel` | exit code 0, actual ISO, hash |
| Virtual boot | UEFI QEMU + edk2-ovmf | boot to live shell, inventory command runs |
| Physical Mac | external USB, non-T2 Intel Mac | completed matrix; macOS recovery remains intact |
| Release | human review | no unresolved critical boot/storage defects |

A script passing syntax is not a successful ISO build. A successful ISO build is not a successful Mac boot.

## Virtual boot planning

On the x86_64 host, install `qemu-desktop` and `edk2-ovmf` as required. Find the OVMF code and variable-template paths in the installed package with `pacman -Ql edk2-ovmf` instead of assuming a single firmware path. Boot the ISO as removable media under a Q35 UEFI VM, retaining the VM console output. Verify `nemesis-hw-report` and networking. This is M03 and is **not yet executed**.

## Physical Mac safety

1. Use a non-T2 Intel Mac as the first physical target; identify the model before any test.
2. Back up macOS and preserve recovery/installer access.
3. Write the verified ISO to a **confirmed removable device**, using a separate user-controlled flashing process; double-check device identity. The repo does not provide an automatic USB writer.
4. Hold Option/Alt at boot for Apple Startup Manager; select external EFI media where available.
5. Run only read-only diagnostics first. Do not run a partitioner or install script during initial acceptance.
6. Capture the Mac model, Wi-Fi chipset, display, input, audio, temperatures, EFI boot behavior and failures privately, then publish only redacted model-level findings.

T2 secure boot and Apple Silicon boot flows must be designed separately and explicitly approved. The first live image makes no claim about support on those targets.

## Evidence template

```text
Commit:
Host / architecture:
archiso version:
Build date:
ISO filename:
SHA-256:
Source validation:
mkarchiso return code:
UEFI VM:
Mac model identifier:
Physical boot:
Hardware findings:
Defects:
Acceptance decision:
```
