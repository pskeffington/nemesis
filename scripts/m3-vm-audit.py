#!/usr/bin/env python3
"""Read-only ARM64 KDE VM baseline; never probes host macOS or changes settings.

This script reports what is visible inside *the Linux guest*. Its output is
not a benchmark, VM attestation, Apple M3 identification, or a boot proof.
No network, privilege, hardware identifiers, or shell commands are used.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import platform
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "spec/m3-arm64-vm.json"


def parse_meminfo(text: str) -> dict[str, int | None]:
    """Only parse aggregate KiB counters; never expose /proc raw contents."""
    result: dict[str, int | None] = {
        "total_mib": None, "available_mib": None
    }
    for key, value in (("MemTotal", "total_mib"), ("MemAvailable", "available_mib")):
        match = re.search(r"^" + key + r":\s+(\d+)\s+kB$", text, re.MULTILINE)
        if match:
            result[value] = int(match.group(1)) // 1024
    return result


def normalized_session(value: str) -> str:
    return value if value in ("wayland", "x11", "tty") else "unknown"


def gpu_driver_class(sysfs: Path = Path("/sys/class/drm")) -> str:
    """Return a coarse category, never PCI identifiers or device information."""
    try:
        for card in sorted(sysfs.glob("card[0-9]*")):
            driver = card / "device" / "driver"
            if not driver.is_symlink():
                continue
            name = driver.resolve().name.lower()
            if "virtio" in name:
                return "virtio"
            if name in ("simpledrm", "simple-framebuffer"):
                return "simple-framebuffer"
            return "other-or-unverified"
    except OSError:
        pass
    return "unknown"


def collect_probe() -> dict:
    try:
        meminfo = Path("/proc/meminfo").read_text(encoding="ascii")
    except OSError:
        meminfo = ""
    return {
        "os": platform.system().lower(),
        "architecture": platform.machine().lower(),
        "logical_cpus": os.cpu_count() or 0,
        "memory": parse_meminfo(meminfo),
        "display_session": normalized_session(os.environ.get("XDG_SESSION_TYPE", "")),
        "plasma_available": bool(shutil.which("plasmashell")),
        "konsole_available": bool(shutil.which("konsole")),
        "graphics_driver_class": gpu_driver_class(),
    }


def assess(probe: dict, profile: dict) -> dict:
    """A preflight gate, not a performance or boot-support certification."""
    minimum = profile["minimum_guest"]
    arch_ok = probe["os"] == "linux" and probe["architecture"] == profile["guest_architecture"]
    cpu_ok = probe["logical_cpus"] >= minimum["vcpus"]
    total = probe["memory"]["total_mib"]
    ram_ok = total is not None and total >= minimum["ram_mib"]
    if not arch_ok:
        status = "OUTSIDE_ARM64_LINUX_GUEST"
    elif not cpu_ok or not ram_ok:
        status = "BELOW_VM_SIZING_BASELINE"
    elif not probe["plasma_available"]:
        status = "ARM64_GUEST_NEEDS_KDE"
    else:
        status = "ARM64_KDE_PREFLIGHT_ONLY"
    return {
        "status": status,
        "linux_aarch64": arch_ok,
        "cpu_budget_met": cpu_ok,
        "ram_budget_met": ram_ok,
        "kde_binary_present": probe["plasma_available"],
        "virtualization_verified": False,
        "actual_m3_host_verified": False,
        "gpu_acceleration_verified": False,
        "gui_boot_verified": False,
        "performance_benchmarked": False,
        "native_asahi_support_verified": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--require-arm64", action="store_true",
        help="exit with status 2 unless this environment is Linux aarch64"
    )
    args = parser.parse_args()
    with PROFILE.open(encoding="utf-8") as stream:
        profile = json.load(stream)
    probe = collect_probe()
    report = {
        "schema_version": 1,
        "profile_id": profile["profile_id"],
        "probe": probe,
        "assessment": assess(probe, profile),
    }
    print(json.dumps(report, indent=2, sort_keys=True))
    return 2 if args.require_arm64 and not report["assessment"]["linux_aarch64"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
