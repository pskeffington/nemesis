"""Fictional 2029 robotics-resilience scenario: transparent, non-operational scoring."""
import json
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
SCHEMA=ROOT/"spec/robotics-2029-capabilities.json"

class RoboticsScenarioTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.spec=json.loads(SCHEMA.read_text())

    def test_scope_and_evidence_limits(self):
        d=self.spec
        self.assertFalse(d["prediction"])
        self.assertFalse(d["observed_usage_data"])
        self.assertFalse(d["measured_macbook_performance"])
        self.assertEqual(d["scoring"]["regression_status"],"BLOCKED_NO_MEASURED_USAGE_OR_RUNTIME_DATA")
        self.assertTrue(d["scenario"].startswith("Fictional"))
        self.assertGreaterEqual(len(d["evidence"]),5)
        for s in d["evidence"]:
            self.assertTrue(s["url"].startswith("https://"))

    def test_score_is_deterministic_and_tiers_are_grounded(self):
        s=self.spec
        w=s["scoring"]["weights"]
        self.assertAlmostEqual(sum(w.values()),1)
        ids=[r["id"] for r in s["rows"]]
        self.assertEqual(len(set(ids)),len(ids))
        self.assertEqual(ids[0],"emergency-checklists")
        for item in s["rows"]:
            self.assertIn(item["tier"],s["tiers"])
            self.assertEqual(item["hardware_status"],"NOT_TESTED")
            self.assertIn(item["primary_operator"],("Bob","Alice"))
            self.assertTrue(item["note"])
            for val in item["criteria"].values():
                self.assertIsInstance(val,int)
                self.assertGreaterEqual(val,1)
                self.assertLessEqual(val,5)
            expected=round(20*sum(w[k]*item["criteria"][k] for k in w))
            self.assertEqual(expected,item["score_100"],item["id"])
        self.assertEqual(ids.index("live-globe")<ids.index("gqrx-gnuradio"),True)

    def test_scenario_does_not_autoinstall_or_authorize_disruption(self):
        for name,val in self.spec["rules"].items():
            self.assertTrue(val,name)
        shipped=(ROOT/"profiles/mac-intel-operator/packages.x86_64").read_text()
        self.assertIn("\ndump1090_rs\n","\n"+shipped)
        self.assertNotIn("\ngqrx\n","\n"+shipped)
        self.assertNotIn("\nqgis\n","\n"+shipped)
        self.assertEqual(next(x["tier"] for x in self.spec["rows"] if x["id"]=="live-globe"),
                         "product-required")

if __name__=="__main__":
    unittest.main()
