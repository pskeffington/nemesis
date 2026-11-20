"""Nemesis Operator edition first-party source, signed-packages and session contract."""

import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class OperatorEditionTests(unittest.TestCase):
    def setUp(self):
        self.op = json.loads((ROOT / "spec/operator-edition.json").read_text())
        self.ed = json.loads((ROOT / "spec/editions.json").read_text())
        self.pkg = json.loads((ROOT / "spec/package-layers.json").read_text())

    def test_dedicated_edition_and_wallpaper_pinning(self):
        ed = next(e for e in self.ed["editions"] if e["id"] == "mac-intel-operator")
        self.assertEqual(ed["status"], "source-scaffold")
        self.assertEqual(ed["platform"], "intel-non-t2")
        self.assertEqual(ed["source_profile"], "archiso-releng")
        self.assertEqual(ed["profile_path"], "profiles/mac-intel-operator")
        self.assertEqual(ed["build_script"], "scripts/build-operator-iso.sh")
        self.assertEqual(self.op["wallpaper"]["home_page"], "https://globe.airplanes.live/")
        self.assertRegex(self.op["wallpaper"]["source_commit"], r"^[0-9a-f]{40}$")
        self.assertEqual(self.op["wallpaper"]["source_repo"], "https://github.com/pskeffington/linux_live_wallpaper.git")
        self.assertEqual(self.op["wallpaper"]["source_license"], "MIT")
        self.assertFalse(self.op["wallpaper"]["downstream_host_tested"])
        for claim in ("build_executed", "boot_verified", "hardware_verified", "release_ready"):
            self.assertIs(ed[claim], False)

    def test_selected_layers_and_unmodified_rescue(self):
        op = next(e for e in self.ed["editions"] if e["id"] == "mac-intel-operator")
        rescue = next(e for e in self.ed["editions"] if e["id"] == "mac-intel")
        self.assertEqual(op["layers"], ["arch-releng", "intel-hardware-overlay",
                                      "macbook-air-field-tools", "mac-desktop-kde", "field-operator"])
        self.assertEqual(rescue["layers"], ["arch-releng", "intel-hardware-overlay"])
        layers = {l["id"]: l for l in self.pkg["layers"]}
        for ident in ("mac-desktop-kde", "field-operator"):
            self.assertTrue(layers[ident]["optional"])
            self.assertFalse(layers[ident]["selected_in_active_scaffold"])
            self.assertEqual(layers[ident]["origin"], "official-arch-delta")
            self.assertTrue((ROOT / layers[ident]["manifest"]).is_file())
        for platform in ("intel-t2", "apple-silicon"):
            self.assertIn("field-operator", self.pkg["platform_exclusions"][platform])
            self.assertIn("mac-desktop-kde", self.pkg["platform_exclusions"][platform])

    def test_package_manifests_and_no_default_services(self):
        for path in (self.op["packages"]["desktop"], self.op["packages"]["operator"]):
            lines = (ROOT / path).read_text().splitlines()
            pkgs = [line.split("#", 1)[0].strip() for line in lines]
            pkgs = [p for p in pkgs if p]
            self.assertEqual(len(pkgs), len(set(pkgs)))
            self.assertTrue(all(re.fullmatch(r"[a-z0-9@._+:-]+", p) for p in pkgs))
            self.assertNotIn("broadcom-wl", pkgs)
            self.assertNotIn("tlp", pkgs)
        desktop = (ROOT / self.op["packages"]["desktop"]).read_text()
        operator = (ROOT / self.op["packages"]["operator"]).read_text()
        for p in ("plasma-desktop", "sddm", "webkitgtk-6.0", "gtk4-layer-shell", "networkmanager"):
            self.assertIn("\n" + p + "\n", "\n" + desktop)
        for p in ("rtl-sdr", "airspy", "dump1090_rs", "usbutils", "jq", "wireguard-tools"):
            self.assertIn("\n" + p + "\n", "\n" + operator)
        for excluded in ("gqrx", "gnuradio", "gpsd", "qgis", "nmap", "rtl_433", "soapyairspy"):
            self.assertNotIn("\n" + excluded + "\n", "\n" + operator,
                             "optional package entered the Operator default")
        for flag in ("internal_storage_write", "default_ssh_listener",
                     "modemmanger_auto_probe", "default_network_credentials",
                     "no_persistent_private_records", "no_untrusted_aur_packages"):
            if flag in ("no_persistent_private_records", "no_untrusted_aur_packages"):
                self.assertIs(self.op["safety"][flag], True)
            else:
                self.assertIs(self.op["safety"][flag], False)
        self.assertTrue(self.op["safety"]["no_passwordless_sudo"])

    def test_image_overlay_and_offline_fallback(self):
        o = self.op["wallpaper"]
        for key in ("launcher_path", "autostart", "offline_fallback"):
            path = ROOT / "profiles/mac-intel-operator/airootfs" / o[key].lstrip("/")
            self.assertTrue(path.is_file(), str(path))
        autostart = (ROOT / "profiles/mac-intel-operator/airootfs" / o["autostart"].lstrip("/")).read_text()
        self.assertIn("OnlyShowIn=KDE;", autostart)
        self.assertIn("Exec=/usr/local/bin/nemesis-operator-wallpaper", autostart)
        self.assertEqual(o["desktop"], "KDE Plasma Wayland")
        self.assertTrue(o["browser_background"])
        self.assertFalse(o["browsing_mode_default"])
        self.assertIn("globe.airplanes.live", (ROOT / "profiles/mac-intel-operator/airootfs" /
                                               o["offline_fallback"].lstrip("/")).read_text())

    def test_ephemeral_operator_login_cannot_lock_out_user(self):
        # The autologin identity has no password. Disabling automatic locking
        # is for the removable live session ONLY, never an installed system.
        live = ROOT / "profiles/mac-intel-operator/airootfs"
        sddm = (live / "etc/sddm.conf.d/10-nemesis-operator-live.conf").read_text()
        locker = (live / "etc/xdg/kscreenlockerrc").read_text()
        self.assertIn("User=operator", sddm)
        self.assertIn("[Daemon]", locker)
        for key in ("Autolock=false", "LockOnResume=false", "RequirePassword=false"):
            self.assertIn(key, locker)
        self.assertFalse((ROOT / "profiles/macbook-air-field/airootfs/etc/xdg/kscreenlockerrc").exists())
        self.assertFalse((ROOT / "profiles/mac-intel/airootfs/etc/xdg/kscreenlockerrc").exists())

    def test_no_claimed_unrun_runtime_checks(self):
        self.assertEqual(set(self.op["ci_gates"].values()), {"NOT_RUN"})
        self.assertFalse(self.op["local_machine_execution_allowed"])
        self.assertEqual(self.op["wallpaper"]["battery_default"], "remain-visible-on-battery")


if __name__ == "__main__":
    unittest.main()
