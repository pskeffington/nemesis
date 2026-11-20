# SIGINT/SDR Linux distribution software-deployment matrix

**Research snapshot:** 2026-11-20. **Decision target:** Nemesis Operator edition for older Intel MacBooks, primarily 4-GiB MacBook Air. Research only; not an endorsement of any distributor's hardware, licensing, legal regime, or security posture. Published software lists are **not** verified ISO inventories or SBOMs. No third-party distribution binaries have been copied.

## Comparative deployments

| System and source | Published distribution and package deployment | Particularly relevant software | Nemesis decision |
| --- | --- | --- | --- |
| [SigintOS 2.0 Community Edition](https://www.sigintos.com/sigintos-2-0-community-edition/) ([download](https://www.sigintos.com/download/)) | Ubuntu-based, GUI-first, broad SDR **and** cellular research and development workstation. The official website calls 2.0 its latest Community Edition but provides a featured-software list rather than a reproducible per-package lockfile/SBOM. | Gqrx, GNU Radio **3.8**, SigDigger, SDRangel, ADSB Viewer, Dump1090, OpenCPN, GPredict, RTL-SDR, HackRF, BladeRF, UHD, **Open5GS, srsRAN 4G, YateBTS**; QtCreator/KDevelop, MySQL/MongoDB/Apache/PHP. | Treat as a **capability catalog, not a preload template**. No cellular lab, web/database servers or entire GNU Radio stack in core. |
| [DragonOS Resolute R2.2](https://sourceforge.net/projects/dragonos-focal/files/) ([maintainer](https://cemaxecuter.com/download/)) | Lubuntu/Ubuntu **26.04**, updated **2026-10-27**, listed ISO **4.0 GB**. Maintainer describes package-managed components plus separately **source-installed software in `/usr/src`**. Hardware coverage is broad; some runtime servers are launched on demand (not enabled by default). | RTL-SDR, Airspy, HackRF, LimeSDR, UHD/USRP, SDRplay, SoapySDR; SDR++, SDRangel, SigDigger, Gqrx, GNU Radio 3.10 and experimental GNU Radio 4; dump1090-fa, dump978-fa, ACARSDEC, DumpVDL2, DumpHFDL, SatDump, GPredict, OpenWebRX+. | Adopt **explicit hardware backend selection**, traceable source provenance, and on-demand services. Reject the assumption that all capable applications must be in the first-boot image. |
| [Skywave Linux 5.10.0](https://skywavelinux.com/downloads) | Debian Sid environment using **DWM** and a broad radio/listening application inventory. Its published list includes many SoapySDR backends and desktop/data tools; its x86-64-v2 targeting must **not** be copied as an unreviewed old-Mac CPU baseline. | SDR++, CubicSDR, SatDump, RTLSDR-Airband, ACARSDEC, DumpHFDL, VDLM2dec, Multimon-ng, GPredict, SoapySDR backends, ham tools. | Highest-value reference for **passive aviation/airband and satellite optional kits**, without its entire browser, development, multimedia and ham ecosystem. |
| [Pentoo](https://www.pentoo.org/about/) ([overlay](https://pentoo.github.io/)) | Gentoo-based XFCE live environment; software selected through a **Pentoo overlay, meta-ebuild and multiple USE-flag-driven profiles**. A modular security distribution, **not** a verified SDR software list. | Overlay/profile engineering, kernel/wireless-security specialization, and selective application stacks. | Copy **modularity as a design principle** only. On Arch, use official signed pacman manifests and explicit operator opt-in; never import Gentoo ebuilds. |

**Comparability:** DragonOS's quoted 4.0 GB and Nemesis's previous ~2.3-GiB Operator ISO are different distro base versions, compression policies, software inventories and provenance. Neither number proves relative efficiency; Nemesis's old ISO also **failed its subsequent payload checker** despite successful image assembly/checksum.

## Application crosswalk: what belongs on a field MacBook?

| Functional family | SigintOS | DragonOS Resolute | Skywave | Nemesis default/kit decision |
| --- | --- | --- | --- | --- |
| Graphical RF monitoring | Gqrx, SigDigger, SDRangel | SDR++, Gqrx, SigDigger, SDRangel, CyberEther | SDR++, CubicSDR | **Optional RF**; one primary GUI is sufficient. The current `rf-lab` kit uses `gqrx`; evaluate lighter signed-Arch `sigdigger`/`inspectrum` independently before altering it. |
| Generic DSP toolkit | GNU Radio 3.8, GR modules | GNU Radio 3.10 plus an experimental GR4 prefix | SoapySDR/decoders; radio tools | **Advanced only**; don't freeze SigintOS's 3.8 version or automatically install a separate GR4 prerelease. |
| SDR hardware drivers | RTL-SDR, HackRF, BladeRF, USRP/UHD | RTL, Airspy, SDRplay, Lime, Pluto, USRP etc. | Multi-vendor SoapySDR modules | **Base RTL-SDR and Airspy** already present; other backends require actual hardware IDs and a separately reviewed package kit. |
| Basic air map/decode | ADSB Viewer, Dump1090 | dump1090-fa, dump978-fa and web map | Airband and aircraft data decoders | **Base `dump1090_rs` and `globe.airplanes.live`**; no automatically running local decoder or remote feeder. |
| Aviation/data links | GPredict, OpenCPN | ACARSDEC, DumpVDL2, DumpHFDL, AIS-Catcher | ACARSDEC, DumpHFDL, VDLM2dec, RTLSDR-Airband | **Research-only aviation-extension kit** after package license/decoder/Arch repo checking; avoid automatic surveillance or capture. |
| Satellites | GPredict | SatDump, gr-satellites, GPredict | SatDump, GPredict | **Optional satellite toolkit candidate**, not a baseline requirement. |
| Signal inspection/demod | SigDigger | inspectrum, URH, multimon-ng, RF GUI tools | multimon-ng and RTL tools | Consider lightweight `sigdigger` / `inspectrum` / `multimon-ng` **as optional analysis**, after dependencies and use-case review. |
| Remote receiver/server | Various server apps | OpenWebRX+, SpyServer, network SDR | Internet radio tools/SoapyRemote | **Service-gated**; never auto-start a listener or port on the Mac. |
| Cellular/core-network testing | Open5GS, srsRAN 4G, YateBTS | srsRAN, Osmocom, LTE/cellular lab tools | Not a core Skywave purpose | **Defer to an isolated authorized lab**; no default active cellular base-station, interception, interference or emitter workflow. |
| General infrastructure | Qt/KDevelop, SQL/NoSQL, Apache/PHP | AI modules and many research executables | JupyterLab, Go, OBS, office/multimedia | **Optional development/data kits**, not part of the live air-map footprint. |

### Verified examples from Arch signed repositories

These names are demonstrably listed by Arch **Extra** (not necessarily part of an already built Nemesis ISO):

- [`sigdigger`](https://archlinux.org/packages/extra/x86_64/sigdigger/) — published ~10 MB direct installed size, depends on Qt/Suscan/Soapy; **candidate** for a lightweight signal GUI instead of bundling several.
- [`inspectrum`](https://archlinux.org/packages/extra/x86_64/inspectrum/) — small direct binary but FFT/Qt dependencies remain; **candidate** for recorded-I/Q inspection.
- [`multimon-ng`](https://archlinux.org/packages/extra/x86_64/multimon-ng/) — small published decoder package; supports several data/digital protocols; **candidate** after receive-lawfulness review.
- [`urh`](https://archlinux.org/packages/extra/x86_64/urh/) — published ~17.5 MB direct installed size and optional RTL/Airspy/other backends; **advanced** tool due to wide protocol capabilities and Python/Qt dependency closure.
- [`soapysdr`](https://archlinux.org/packages/extra/x86_64/soapysdr/) — existing `dump1090_rs` requires it, so no claim that deleting an explicit `soapysdr` request would remove it from the core dependency closure.
- [`gnuradio`](https://archlinux.org/packages/extra/x86_64/gnuradio/) — a relatively small *direct* installed-size number masks an extensive framework and Python/library dependency closure. Keep the whole runtime in opt-in `rf-lab`.

**Rule:** official distro software *names* are not necessarily current official Arch *package* names. No new toolkit manifests are enabled from this survey. Before adding any candidate, require `pacman -Si` against official signed CI repositories, compare unique dependency closures, and record licensing/service behavior.

## Deployment design drawn from the literature

1. **Essential first-boot image:** KDE/Wayland, pinned first-party globe wallpaper and offline static fallback, Firefox for interaction, NetworkManager, terminal/files, hardware diagnostic, RTL-SDR/Airspy utilities and basic manually invoked ADS-B. Keep the existing MacBook Air recovery/USB-network foundation.
2. **Ready-to-select toolkits:** seven current signed-Arch manifests in [operator-kits.json](../../spec/operator-kits.json); they are read-only manifests in the live image, not auto-installs.
3. **Research candidates, not yet packaged:** light RF inspection, expanded aviation/VHF decoding, satellite processing and specialized hardware driver selection. Require signed package availability, dependency measurements and actual operator workflows before creating additional kits.
4. **Isolated laboratories only:** cellular base station and experimental active RF/electromagnetic functions; no default auto-start, unreviewed radio transmission, credential capture or resident network listeners.
5. **Provenance:** mirror DragonOS's explicit separation of package-managed vs from-source software *as a recordkeeping discipline*. Nemesis already pins and hashes the first-party Rust wallpaper; other foreign distro binaries must not be imported into Arch without an independent supply-chain decision.
6. **Benchmark and acceptance:** stage actual signed Arch sources, inventory packages/versions and sizes, measure an ISO and then validate KDE runtime and 4-GiB Mac power/USB/network behavior. A published catalog or source commit is not boot evidence.

## Decision register

| ID | Decision | Current state | Evidence required to change |
| --- | --- | --- | --- |
| SO-01 | No monolithic SigintOS/DragonOS package transplant | ACCEPTED as research policy | Explicit per-package signed source, dependency and service review |
| SO-02 | Keep current essential receiver and map core | ACCEPTED as source decision, not hardware | Real native Arch/ISO staging, compositor, Mac model tests |
| SO-03 | Compare `sigdigger` and `inspectrum` with `gqrx` | RESEARCH CANDIDATE | Dependency graph, measured memory/size, useful operator task |
| SO-04 | Investigate extended aviation/airband + satellite kit | RESEARCH CANDIDATE | Package names, licensing, UI, receiver capability, on-demand operations |
| SO-05 | Lab-only cellular/experimental TX suites | DEFERRED | Independently approved isolated laboratory and compliance requirements |
| SO-06 | Keep published inventories separate from installed SBOM | ACTIVE RULE | Per-ISO package inventory plus build SHA/sidecar |
| SO-07 | Use Pentoo-like selective profiles only at source-package layer | ACCEPTED as design analogy | Native Arch implementation and reproducible CI, not Gentoo overlay |

**Scope remains repo-side only.** No local Mac/Garuda, SDR device, QEMU or USB operation was performed for this research.
