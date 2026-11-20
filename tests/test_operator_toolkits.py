"""Read-only Operator toolkit, verified manifest and install-boundary contracts."""

import json
import os
from pathlib import Path
import re
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
KITS = ROOT / "profiles/mac-intel-operator/toolkits"
CORE = ROOT / "profiles/mac-intel-operator/packages.x86_64"
APP = ROOT / "profiles/mac-intel-operator/airootfs/usr/local/bin/nemesis-kit"
SPEC = ROOT / "spec/operator-kits.json"
NAME = re.compile(r"^[a-z0-9@._+:-]+$")


def packages(path):
    values = []
    for line in path.read_text().splitlines():
        value = line.split("#", 1)[0].strip()
        if value:
            assert NAME.fullmatch(value), (path, value)
            values.append(value)
    return values


class OperatorKitTests(unittest.TestCase):
    def setUp(self):
        self.spec = json.loads(SPEC.read_text(encoding="utf-8"))

    def test_each_kit_is_source_owned_and_unique(self):
        self.assertEqual(self.spec["edition"], "mac-intel-operator")
        self.assertEqual(self.spec["installer_status"], "not-implemented")
        kits = self.spec["kits"]
        self.assertEqual(len(kits), 7)
        self.assertEqual([x["id"] for x in kits],
                         ["aviation", "airspy", "gnss", "network", "rf-lab",
                          "development", "gis"])
        for entry in kits:
            self.assertFalse(entry["default_installed"])
            path = ROOT / entry["manifest"]
            self.assertTrue(path.is_file(), str(path))
            values = packages(path)
            self.assertTrue(values)
            self.assertEqual(len(values), len(set(values)))

    def test_core_excludes_heavy_tier(self):
        default = packages(CORE)
        excluded = ("gqrx", "gnuradio", "gpsd", "qgis", "nmap",
                    "tcpdump", "rtl_433", "soapyairspy")
        for name in excluded:
            self.assertNotIn(name, default)
        for name in ("rtl-sdr", "airspy", "dump1090_rs",
                     "usbutils", "pciutils", "jq"):
            self.assertIn(name, default)

    def test_reviewed_releng_drop_is_separate_from_rescue(self):
        path = ROOT / self.spec["releng_drop_manifest"]
        dropped = packages(path)
        self.assertEqual(len(dropped), len(set(dropped)))
        self.assertIn("nmap", dropped)
        self.assertIn("tcpdump", dropped)
        for critical in ("base", "linux", "linux-firmware", "intel-ucode",
                         "wpa_supplicant", "archinstall", "mkinitcpio-archiso"):
            self.assertNotIn(critical, dropped)
        self.assertFalse((ROOT / "profiles/mac-intel/releng-drop.packages.x86_64").exists())

    def test_list_show_and_install_rejection_are_read_only(self):
        env = os.environ.copy()
        env["NEMESIS_KITS_TEST_DIR"] = str(KITS)
        result = subprocess.run(["bash", str(APP), "list"], env=env,
                                capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("aviation", result.stdout)
        view = subprocess.run(["bash", str(APP), "show", "rf-lab"], env=env,
                              capture_output=True, text=True, check=False)
        self.assertEqual(view.returncode, 0, view.stderr)
        self.assertIn("gqrx", view.stdout)
        forbidden = subprocess.run(["bash", str(APP), "install", "rf-lab"],
                                   env=env, capture_output=True, text=True, check=False)
        self.assertNotEqual(forbidden.returncode, 0)
        self.assertIn("test override forbidden", forbidden.stderr)
        traversal = subprocess.run(["bash", str(APP), "show", "../tmp"],
                                   env=env, capture_output=True, text=True, check=False)
        self.assertNotEqual(traversal.returncode, 0)

    def test_live_wallpaper_is_not_replaced(self):
        overlay = ROOT / "profiles/mac-intel-operator/airootfs"
        autostart = (overlay / "etc/xdg/autostart/nemesis-operator-wallpaper.desktop").read_text()
        self.assertIn("/usr/local/bin/nemesis-operator-wallpaper", autostart)
        launcher = (overlay / "usr/local/bin/nemesis-operator-wallpaper").read_text()
        self.assertIn("https://globe.airplanes.live/", launcher)


if __name__ == "__main__":
    unittest.main()
