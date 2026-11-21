"""M3 Codex graphical handoff contracts (never open a VM or hardware)."""
from __future__ import annotations

import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = json.loads((ROOT / "spec/m3-gui-acceptance.json").read_text())
SOURCE = ROOT / "scripts/validate_m3_gui_report.py"
module_spec = importlib.util.spec_from_file_location("m3_gui_validator", SOURCE)
assert module_spec is not None and module_spec.loader is not None
validator = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(validator)


class M3GuiCodexContractTests(unittest.TestCase):
    def test_readiness_contract_has_separate_virtual_and_native_gates(self):
        self.assertEqual(SPEC["pass_id"], "M3-GUI-V01")
        self.assertEqual(SPEC["current_acceptance"], "NOT_RUN")
        self.assertIn("UTM", SPEC["environment"]["virtualization"])
        self.assertEqual(SPEC["environment"]["guest_architecture"], "aarch64")
        ids = [x["id"] for x in SPEC["cases"]]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertGreaterEqual(len(ids), 10)
        for key in ("BOOT-01", "OBJ-01", "INPUT-01", "SCALE-01", "SCALE-02", "RESTORE-01"):
            self.assertIn(key, ids)
        self.assertEqual(SPEC["acceptance_semantics"]["source_ci"], "not_gui_boot")
        self.assertTrue(SPEC["evidence_policy"]["no_raw_guest_screenshots_committed_to_repo"])

    def test_unobserved_default_report_is_not_a_pass(self):
        report = validator.template(SPEC)
        self.assertEqual(report["overall"], "NOT_RUN")
        self.assertEqual(validator.validate(report, SPEC), [])
        self.assertTrue(all(x["status"] == "NOT_RUN" for x in report["results"]))

    def test_pass_requires_observations_and_immutable_source(self):
        report = validator.template(SPEC)
        report["overall"] = "PASS"
        errors = validator.validate(report, SPEC)
        self.assertIn("Overall status must be NOT_RUN", errors)
        for record in report["results"]:
            if record["id"] != "NATIVE-M3-01":
                record.update(status="PASS", observed_at_utc="2026-11-21T10:00:00Z",
                              evidence_refs=[f"private-local/{record['id']}.png"],
                              actual="Observed with a guest screenshot or guest metrics")
        report.update(source_commit="a" * 40, host_class="Apple M3 family macOS",
                      guest_architecture="aarch64")
        self.assertEqual(validator.validate(report, SPEC), [])
        report["results"][1]["evidence_refs"] = []
        self.assertTrue(any("needs an evidence reference" in e for e in validator.validate(report, SPEC)))
        report["results"][1]["evidence_refs"] = ["../untrusted/image.png"]
        self.assertTrue(any("sanitized relative references" in e for e in validator.validate(report, SPEC)))

    def test_native_m3_is_never_certified_by_vm_evidence(self):
        report = validator.template(SPEC)
        report["native_asahi"] = "PASS"
        self.assertTrue(any("outside this UTM" in e for e in validator.validate(report, SPEC)))
        report["native_asahi"] = "NOT_RUN"
        record = next(x for x in report["results"] if x["id"] == "NATIVE-M3-01")
        record["status"] = "PASS"
        self.assertTrue(any("must remain NOT_RUN" in e for e in validator.validate(report, SPEC)))

    def test_failure_and_blocker_precedence(self):
        report = validator.template(SPEC)
        report["results"][0]["status"] = "BLOCKED"
        self.assertIn("Overall status must be BLOCKED", validator.validate(report, SPEC))
        report["overall"] = "BLOCKED"
        self.assertEqual(validator.validate(report, SPEC), [])
        report["results"][1]["status"] = "FAIL"
        self.assertIn("Overall status must be FAIL", validator.validate(report, SPEC))

    def test_cli_template_requires_no_machine_or_github_access(self):
        cmd = subprocess.run([sys.executable, str(SOURCE), "--template"],
                             capture_output=True, text=True, check=True)
        data = json.loads(cmd.stdout)
        self.assertEqual(data["overall"], "NOT_RUN")
        self.assertEqual(data["host_class"], "NOT_VERIFIED")

    def test_codex_local_go_gate_is_explicit(self):
        handoff = (ROOT / "codex/M3_GRAPHICAL_VALIDATION_PASS.md").read_text()
        for token in ("Phase A", "Phase B", "explicit GO", "BLOCKED_NEEDS_USER",
                      "M3-GUI-V01", "native Asahi", "source SHA"):
            self.assertIn(token, handoff)
        self.assertNotIn("M3-GUI-V01 ACCEPTED", handoff)


if __name__ == "__main__":
    unittest.main()
