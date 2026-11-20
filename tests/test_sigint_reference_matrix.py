"""Source-review guard for externally published SDR/SIGINT distro inventories."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SigintReferenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads((ROOT / "spec/sigint-distro-references.json").read_text())

    def test_sources_are_distinct_and_architectures_are_not_conflated(self):
        distros = self.data["distributions"]
        self.assertEqual({x["id"] for x in distros},
                         {"sigintos", "dragonos", "skywave", "pentoo"})
        self.assertEqual(len(distros), 4)
        for distro in distros:
            self.assertTrue(distro["sources"])
            self.assertTrue(all(url.startswith("https://") for url in distro["sources"]))
            self.assertTrue(distro["listed_software"])
            self.assertIn("inventory_basis", distro)
        self.assertIn("Gentoo", next(x for x in distros
                                    if x["id"] == "pentoo")["platform"])
        self.assertIn("Ubuntu", next(x for x in distros
                                     if x["id"] == "sigintos")["platform"])

    def test_comparison_cannot_turn_into_automatic_install(self):
        policy = self.data["source_trust_policy"]
        for key in ("arch_package_names_must_be_resolved_in_signed_ci",
                    "not_a_binary_bill_of_materials",
                    "advertised_not_proven_installed",
                    "no_auto_transmit_or_interception",
                    "no_default_services", "do_not_modify_current_core"):
            self.assertIs(policy[key], True)
        self.assertEqual(self.data["kind"],
                         "public-distribution-published-inventory-not-verified-ISO-SBOM")
        self.assertNotIn("install_script", self.data)

    def test_research_candidate_does_not_enter_essential_package_lists(self):
        core = (
            (ROOT / "profiles/mac-intel-operator/packages.x86_64").read_text()
            + "\n"
            + (ROOT / "profiles/mac-intel-operator/desktop.packages.x86_64").read_text()
        )
        names = {
            line.strip() for line in core.splitlines()
            if line.strip() and not line.strip().startswith("#")
        }
        for name in ("gnuradio", "gqrx", "sigdigger", "inspectrum", "urh",
                     "satdump", "open5gs", "yatebts", "apache", "mariadb"):
            self.assertNotIn(name, names)
        self.assertIn("dump1090_rs", names)
        self.assertIn("rtl-sdr", names)
        self.assertIn("airspy", names)

    def test_each_capability_class_has_a_reviewed_disposition(self):
        rows = self.data["evaluated_capabilities"]
        self.assertGreaterEqual(len(rows), 7)
        self.assertEqual(len({r["id"] for r in rows}), len(rows))
        allowed = {"default", "optional-review", "rf-lab-only",
                   "optional-research", "separately-review-service",
                   "isolated-lab-deferred", "not-default", "hardware-selected"}
        for row in rows:
            self.assertIn(row["nemesis_tier"], allowed)
            self.assertTrue(row["reason"])
            self.assertTrue(row["examples"])


if __name__ == "__main__":
    unittest.main()
