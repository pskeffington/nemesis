"""M3 VM source contracts. No physical Mac, QEMU, or device access."""
from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import platform
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "scripts/m3-vm-audit.py"
PROFILE = ROOT / "spec/m3-arm64-vm.json"
spec = importlib.util.spec_from_file_location("m3_vm_audit", MODULE)
assert spec and spec.loader
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class M3VmOptimizationContracts(unittest.TestCase):
    def setUp(self):
        self.profile = json.loads(PROFILE.read_text(encoding="utf-8"))
        self.good_probe = {
            "os": "linux",
            "architecture": "aarch64",
            "logical_cpus": 4,
            "memory": {"total_mib": 6144, "available_mib": 3900},
            "display_session": "wayland",
            "plasma_available": True,
            "konsole_available": True,
            "graphics_driver_class": "virtio",
        }

    def test_architecture_and_isolation_contract(self):
        data = self.profile
        self.assertEqual(data["guest_architecture"], "aarch64")
        self.assertIn("generic-UEFI-virtio", data["guest_platform"])
        self.assertEqual(data["current_stage"], "source-validation-only")
        for key, value in data["safety"].items():
            if key.startswith(("change_", "write_", "install_", "request_", "assume_", "build_", "enable_")):
                self.assertFalse(value, key)
        self.assertTrue(data["safety"]["native_asahi_deployment_requires_separate_go"])
        self.assertTrue(data["native_asahi"]["baseline_not_equivalent_to_vm"])
        self.assertEqual(data["native_asahi"]["stage"], "research-only")

    def test_sizing_presets_leave_room_for_macos(self):
        presets = self.profile["sizing_presets"]
        self.assertEqual(len(presets), 3)
        for p in presets:
            self.assertGreaterEqual(p["guest_vcpus"], 2)
            self.assertGreaterEqual(p["guest_ram_mib"], 4096)
            self.assertLess(p["guest_ram_mib"], p["host_ram_gib"] * 1024)
            self.assertGreaterEqual(p["guest_disk_gib"], 32)
        self.assertLessEqual(presets[0]["guest_ram_mib"], presets[1]["guest_ram_mib"])

    def test_memory_parse_only_aggregate_counters(self):
        value = "MemTotal:        6291456 kB\nMemAvailable:   3145728 kB\n"
        self.assertEqual(audit.parse_meminfo(value), {
            "total_mib": 6144, "available_mib": 3072
        })
        self.assertEqual(audit.parse_meminfo("garbage"), {
            "total_mib": None, "available_mib": None
        })
        self.assertEqual(audit.normalized_session("wayland"), "wayland")
        self.assertEqual(audit.normalized_session("arbitrary identifier"), "unknown")

    def test_source_gate_does_not_claim_boot_or_gpu(self):
        status = audit.assess(self.good_probe, self.profile)
        self.assertEqual(status["status"], "ARM64_KDE_PREFLIGHT_ONLY")
        self.assertTrue(status["linux_aarch64"])
        for key in ("virtualization_verified", "actual_m3_host_verified",
                    "gpu_acceleration_verified", "gui_boot_verified",
                    "performance_benchmarked", "native_asahi_support_verified"):
            self.assertFalse(status[key], key)

    def test_x86_and_underprovisioned_guests_are_not_accepted(self):
        wrong = dict(self.good_probe, architecture="x86_64")
        self.assertEqual(audit.assess(wrong, self.profile)["status"], "OUTSIDE_ARM64_LINUX_GUEST")
        small = dict(self.good_probe, logical_cpus=1)
        self.assertEqual(audit.assess(small, self.profile)["status"], "BELOW_VM_SIZING_BASELINE")
        lowmem = dict(self.good_probe, memory={"total_mib": 2048, "available_mib": 1024})
        self.assertEqual(audit.assess(lowmem, self.profile)["status"], "BELOW_VM_SIZING_BASELINE")
        missing = dict(self.good_probe, plasma_available=False)
        self.assertEqual(audit.assess(missing, self.profile)["status"], "ARM64_GUEST_NEEDS_KDE")

    def test_cli_reports_no_sensitive_identifiers(self):
        result = subprocess.run(
            [sys.executable, str(MODULE)], capture_output=True, text=True, check=True
        )
        data = json.loads(result.stdout)
        self.assertEqual(data["schema_version"], 1)
        self.assertEqual(data["profile_id"], self.profile["profile_id"])
        raw = result.stdout.lower()
        for forbidden in ("serial_number", "mac_address", "hostname", "ip_address",
                          "username", "wifi_ssid", "device_id"):
            self.assertNotIn(forbidden, raw)

    def test_strict_architecture_guard(self):
        result = subprocess.run(
            [sys.executable, str(MODULE), "--require-arm64"],
            capture_output=True, text=True
        )
        supported = platform.system().lower() == "linux" and platform.machine().lower() == "aarch64"
        self.assertEqual(result.returncode, 0 if supported else 2)

    def test_existing_intel_pipeline_is_untouched(self):
        for source in (
            "scripts/prepare-operator-profile.sh",
            "scripts/prepare-air-field-profile.sh",
            "scripts/prepare-profile.sh",
            "scripts/build-operator-iso.sh",
        ):
            self.assertNotIn("m3-vm", (ROOT / source).read_text())
        self.assertEqual(
            json.loads((ROOT / "spec/editions.json").read_text())["phase_policy"]["physical_mac_test"],
            "deferred"
        )
        self.assertTrue((ROOT / "brand/scripts/dragonized.py").is_file())


if __name__ == "__main__":
    unittest.main()
