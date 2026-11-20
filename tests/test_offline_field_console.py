"""Offline Operator console: local-only GeoJSON viewer and manual notebook.

Only Python stdlib and local temp files are used. No Mac, SDR, network,
geolocation or privileged actions occur in this test.
"""
import json
import os
from html.parser import HTMLParser
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "profiles/mac-intel-operator/airootfs"
NOTE = OVERLAY / "usr/local/bin/nemesis-field-note"
MAP = OVERLAY / "usr/share/nemesis-operator/offline-field-map.html"
CONTRACT = ROOT / "spec/offline-field-console.json"


class InlineScriptParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_script = False
        self.scripts = []

    def handle_starttag(self, tag, attrs):
        if tag == "script":
            self.in_script = True

    def handle_endtag(self, tag):
        if tag == "script":
            self.in_script = False

    def handle_data(self, data):
        if self.in_script:
            self.scripts.append(data)


class OfflineFieldConsoleTests(unittest.TestCase):
    def test_contract_is_source_only_and_never_autocaptures(self):
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(data["edition"], "mac-intel-operator")
        self.assertEqual(data["pass_id"], "R29-03")
        self.assertEqual(data["status"], "SOURCE_COMMITTED")
        self.assertEqual(data["basemap_status"], "NOT_PROVIDED")
        self.assertEqual(data["routing_status"], "NOT_IMPLEMENTED")
        self.assertFalse(data["network_requirements"]["requires_network"])
        for key in ("automatic_location", "automatic_camera", "automatic_radio",
                    "automatic_export", "automatic_network"):
            self.assertFalse(data["privacy"][key])
        for key in ("meshtastic", "remote_id"):
            self.assertEqual(data["companions"][key]["status"], "DEFERRED")

    def test_map_is_file_only_with_bounded_geojson_and_csp(self):
        html = MAP.read_text(encoding="utf-8")
        self.assertIn("connect-src 'none'", html)
        self.assertIn("default-src 'none'", html)
        self.assertIn('type="file"', html)
        self.assertIn("FeatureCollection", html)
        self.assertIn("maxBytes = 5 * 1024 * 1024", html)
        self.assertIn("maxVertices = 30000", html)
        self.assertIn("status.textContent", html)
        self.assertIn("no basemap", html.lower())
        self.assertNotIn("navigator.geolocation", html)
        self.assertNotIn("XMLHttpRequest", html)
        self.assertNotIn("fetch(", html)
        self.assertNotIn("<iframe", html)
        self.assertNotIn("http://", html)
        self.assertNotIn("https://", html)
        desktop = (OVERLAY / "usr/share/applications/nemesis-operator-offline-map.desktop").read_text()
        self.assertIn("file:///usr/share/nemesis-operator/offline-field-map.html", desktop)

    @unittest.skipUnless(shutil.which("node"), "Node executable unavailable for JS syntax check")
    def test_embedded_javascript_syntax(self):
        parser = InlineScriptParser()
        parser.feed(MAP.read_text(encoding="utf-8"))
        self.assertEqual(len(parser.scripts), 1)
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "offline-map.js"
            file.write_text(parser.scripts[0], encoding="utf-8")
            result = subprocess.run(["node", "--check", str(file)],
                                    capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_only_operator_owns_the_offline_console(self):
        self.assertTrue(NOTE.is_file())
        self.assertTrue(bool(NOTE.stat().st_mode & stat.S_IXUSR))
        for edition in ("mac-intel", "macbook-air-field"):
            path = ROOT / ("profiles/" + edition + "/airootfs/usr/local/bin/nemesis-field-note")
            self.assertFalse(path.exists(), str(path))
        notes_launcher = (OVERLAY / "usr/share/applications/nemesis-operator-field-notes.desktop").read_text()
        self.assertIn("/usr/local/bin/nemesis-field-note --help", notes_launcher)

    @unittest.skipIf(os.geteuid() == 0, "notebook intentionally refuses root execution")
    def test_note_insert_list_status_and_explicit_private_export(self):
        with tempfile.TemporaryDirectory() as tmp:
            data = Path(tmp) / "data"
            env = os.environ.copy()
            env["NEMESIS_FIELD_NOTES_DIR"] = str(data)

            def call(*args):
                return subprocess.run([sys.executable, str(NOTE), *args],
                                      env=env, capture_output=True, text=True, check=False)

            add = call("add", "--category", "observation", "--text", "Trail closed; use verified route.")
            self.assertEqual(add.returncode, 0, add.stderr)
            self.assertIn("Saved local record 1", add.stdout)
            add2 = call("add", "--category", "system", "--text", "Battery inspected")
            self.assertEqual(add2.returncode, 0, add2.stderr)

            count = call("status")
            self.assertEqual(count.returncode, 0, count.stderr)
            self.assertIn("Local records: 2", count.stdout)
            recent = call("list", "--limit", "1")
            self.assertEqual(recent.returncode, 0, recent.stderr)
            self.assertIn("Battery inspected", recent.stdout)
            self.assertNotIn("Trail closed", recent.stdout)

            self.assertEqual(stat.S_IMODE(data.stat().st_mode), 0o700)
            self.assertEqual(stat.S_IMODE((data / "field-notes.sqlite3").stat().st_mode), 0o600)
            output = Path(tmp) / "notes-export.jsonl"
            exported = call("export", "--output", str(output))
            self.assertEqual(exported.returncode, 0, exported.stderr)
            self.assertEqual(stat.S_IMODE(output.stat().st_mode), 0o600)
            records = [json.loads(line) for line in output.read_text().splitlines()]
            self.assertEqual(len(records), 2)
            self.assertEqual(records[0]["category"], "observation")
            self.assertIn("Trail closed", records[0]["note"])
            self.assertTrue(records[0]["utc"].endswith("+00:00"))
            repeat = call("export", "--output", str(output))
            self.assertNotEqual(repeat.returncode, 0)
            self.assertIn("refusing overwrite", repeat.stderr)

    @unittest.skipIf(os.geteuid() == 0, "notebook intentionally refuses root execution")
    def test_rejects_invalid_notes_and_symlinks_without_data_leaks(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = os.environ.copy()
            env["NEMESIS_FIELD_NOTES_DIR"] = str(Path(tmp) / "data")

            def call(*args):
                return subprocess.run([sys.executable, str(NOTE), *args],
                                      env=env, capture_output=True, text=True, check=False)

            for text in ("", "x" * 501, "line one\nline two"):
                result = call("add", "--category", "observation", "--text", text)
                self.assertNotEqual(result.returncode, 0)
            wrong = call("add", "--category", "unreviewed", "--text", "test")
            self.assertNotEqual(wrong.returncode, 0)
            limit = call("list", "--limit", "999999")
            self.assertNotEqual(limit.returncode, 0)
            self.assertEqual(call("status").returncode, 0)
            protected = Path(tmp) / "real.txt"
            protected.write_text("existing", encoding="utf-8")
            link = Path(tmp) / "export.jsonl"
            link.symlink_to(protected)
            result = call("export", "--output", str(link))
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(protected.read_text(), "existing")
            db = Path(tmp) / "data" / "field-notes.sqlite3"
            db.unlink()
            db.symlink_to(protected)
            self.assertNotEqual(call("status").returncode, 0)


if __name__ == "__main__":
    unittest.main()
