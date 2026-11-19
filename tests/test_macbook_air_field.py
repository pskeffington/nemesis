"""Field-laptop source contract: optional profile, no hardware acceptance claims."""

import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "spec/macbook-air-field.json"
EDITION = ROOT / "spec/editions.json"
LAYERS = ROOT / "spec/package-layers.json"


class MacBookAirFieldContractTests(unittest.TestCase):
    def setUp(self):
        self.spec = json.loads(SOURCE.read_text(encoding="utf-8"))
        self.editions = json.loads(EDITION.read_text(encoding="utf-8"))
        self.layers = json.loads(LAYERS.read_text(encoding="utf-8"))

    def test_field_edition_is_optional_and_not_built(self):
        self.assertEqual(self.spec["contract_version"], 1)
        self.assertEqual(self.spec["edition"], "macbook-air-field")
        self.assertEqual(self.spec["platform"], "intel-non-t2")
        self.assertIs(self.spec["applied_by_builder"], True)
        self.assertEqual(self.spec["build_validation_status"], "NOT_TESTED")
        for key in ("built_in_docker", "physically_tested",
                    "broadcom_wl_bundled", "operator_profile_bundled",
                    "ssh_server_auto_enabled", "sensors_or_fans_modified",
                    "battery_tuning_auto_enabled", "usb_autosuspend_auto_enabled"):
            self.assertIs(self.spec[key], False, key)
        e = next(x for x in self.editions["editions"] if x["id"] == self.spec["edition"])
        self.assertEqual(e["status"], "source-scaffold")
        self.assertEqual(e["platform"], "intel-non-t2")
        self.assertEqual(e["build_script"], "scripts/build-air-field-iso.sh")
        self.assertEqual(e["prepare_script"], "scripts/prepare-air-field-profile.sh")
        self.assertEqual(e["packages_manifest"], self.spec["package_manifest"])
        self.assertIn("macbook-air-field-tools", e["layers"])
        core = next(x for x in self.editions["editions"] if x["id"] == "mac-intel")
        self.assertNotIn("macbook-air-field-tools", core["layers"])

    def test_platform_and_package_isolation(self):
        layer = next(x for x in self.layers["layers"] if x["id"] == "macbook-air-field-tools")
        self.assertIs(layer["selected_in_active_scaffold"], False)
        self.assertIs(layer["optional"], True)
        self.assertEqual(layer["depends_on"], ["intel-hardware-overlay"])
        for p in ("intel-t2", "apple-silicon"):
            self.assertIn("macbook-air-field-tools", self.layers["platform_exclusions"][p])
        manifest = ROOT / self.spec["package_manifest"]
        self.assertTrue(manifest.is_file())
        packages = [line.split("#", 1)[0].strip()
                    for line in manifest.read_text(encoding="utf-8").splitlines()]
        packages = [p for p in packages if p]
        self.assertEqual(len(packages), len(set(packages)))
        self.assertTrue(all(re.fullmatch(r"[a-z0-9@._+:-]+", p) for p in packages))
        self.assertEqual(set(packages), {"bluez", "bluez-utils", "powertop", "wireguard-tools"})
        self.assertNotIn("tlp", packages)
        self.assertNotIn("broadcom-wl", packages)

    def test_source_only_candidates_and_features(self):
        expected = {"MacBookAir5,1", "MacBookAir5,2", "MacBookAir6,1",
                    "MacBookAir6,2", "MacBookAir7,1", "MacBookAir7,2"}
        observed = {x["model"] for x in self.spec["candidates"]}
        self.assertEqual(observed, expected)
        self.assertTrue(all(x["status"] == "NOT_TESTED" for x in self.spec["candidates"]))
        self.assertTrue(all(x["status"] == "NOT_TESTED" for x in self.spec["proposed_acceptance"]))
        self.assertEqual(len(set(x["id"] for x in self.spec["proposed_acceptance"])),
                         len(self.spec["proposed_acceptance"]))
        self.assertIn("MacBookAir8,1", self.spec["excluded"])
        self.assertIn("Apple Silicon MacBook Air", self.spec["excluded"])
        sources = self.spec["sources"]
        for candidate in self.spec["candidates"]:
            self.assertTrue(candidate["source_ids"])
            self.assertTrue(set(candidate["source_ids"]).issubset(sources))

    def test_no_automatic_field_perturbations(self):
        policies = self.spec["policies"]
        self.assertIs(policies["network"]["offline_first"], True)
        self.assertIs(policies["network"]["automated_wifi_driver_install"], False)
        self.assertIs(policies["power"]["tlp_auto_enabled"], False)
        self.assertIs(policies["power"]["power_profiles_daemon_auto_enabled"], False)
        self.assertIs(policies["security"]["auto_enable_ssh"], False)
        self.assertIs(policies["security"]["internal_disk_mutation"], False)
        self.assertIs(policies["security"]["firmware_extraction"], False)
        self.assertIs(policies["modularity"]["releng_rescue_baseline_preserved"], True)

    def test_read_only_script_with_fake_sysfs(self):
        script = ROOT / self.spec["diagnostic_script"]
        self.assertTrue(script.is_file())
        script_text = script.read_text(encoding="utf-8")
        self.assertIn("set -euo pipefail", script_text)
        self.assertNotIn("sudo ", script_text)
        self.assertNotIn("modprobe ", script_text)
        self.assertNotIn("rfkill block", script_text)
        with tempfile.TemporaryDirectory() as scratch:
            root = Path(scratch)
            values = {
                "class/dmi/id/product_name": "MacBookAir7,2\n",
                "class/power_supply/BAT0/type": "Battery\n",
                "class/power_supply/BAT0/status": "Discharging\n",
                "class/power_supply/BAT0/capacity": "63\n",
                "class/power_supply/BAT0/energy_full": "38000000\n",
                "class/power_supply/BAT0/energy_full_design": "46000000\n",
                "class/power_supply/AC/type": "Mains\n",
                "class/power_supply/AC/online": "0\n",
                "class/thermal/thermal_zone0/type": "x86_pkg_temp\n",
                "class/thermal/thermal_zone0/temp": "45000\n",
                "power/mem_sleep": "s2idle [deep]\n",
                "module/usbcore/parameters/autosuspend": "2\n",
            }
            for name, val in values.items():
                target = root / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(val, encoding="utf-8")
            env = os.environ.copy()
            env["NEMESIS_FIELD_SYSFS_ROOT"] = str(root)
            result = subprocess.run(["bash", str(script)], capture_output=True,
                                    text=True, env=env, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MacBookAir7,2", result.stdout)
        self.assertIn("capacity=63%", result.stdout)
        self.assertIn("temperature_mC=45000", result.stdout)
        self.assertIn("no configuration, device", result.stdout.lower())


if __name__ == "__main__":
    unittest.main()
