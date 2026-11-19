"""Repository-phase contract tests; no ISO, root, Linux hardware, or network needed."""

import json
import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec" / "editions.json"
SAFE_ID = re.compile(r"^[a-z0-9][a-z0-9-]*$")


def load_contract():
    with SPEC.open(encoding="utf-8") as handle:
        return json.load(handle)


class FoundationContractTests(unittest.TestCase):
    def setUp(self):
        self.spec = load_contract()

    def test_repository_phase_does_not_claim_execution(self):
        phases = self.spec["phase_policy"]
        self.assertEqual(self.spec["contract_version"], 1)
        self.assertEqual(self.spec["current_phase"], "repo-foundation")
        self.assertEqual(phases["repo_foundation"], "active")
        for phase in ("linux_iso_build", "vm_boot", "physical_mac_test", "installation"):
            self.assertEqual(phases[phase], "deferred")
        for edition in self.spec["editions"]:
            for claim in ("build_executed", "boot_verified", "hardware_verified", "release_ready"):
                self.assertIs(edition[claim], False, (edition["id"], claim))

    def test_platforms_and_edition_identifiers(self):
        platforms = self.spec["platforms"]
        editions = self.spec["editions"]
        platform_ids = [p["id"] for p in platforms]
        edition_ids = [e["id"] for e in editions]
        self.assertEqual(len(platform_ids), len(set(platform_ids)))
        self.assertEqual(len(edition_ids), len(set(edition_ids)))
        self.assertTrue(all(SAFE_ID.fullmatch(x) for x in platform_ids + edition_ids))
        self.assertEqual({p["id"]: p["arch"] for p in platforms}, {
            "intel-non-t2": "x86_64",
            "intel-t2": "x86_64",
            "apple-silicon": "aarch64",
        })
        for edition in editions:
            self.assertIn(edition["platform"], platform_ids)

    def test_buildable_scaffold_is_intel_only(self):
        scaffolded = [e for e in self.spec["editions"] if e["status"] == "source-scaffold"]
        self.assertEqual([e["id"] for e in scaffolded], ["mac-intel"])
        active = scaffolded[0]
        self.assertEqual(active["platform"], "intel-non-t2")
        self.assertEqual(active["source_profile"], "archiso-releng")
        for key in ("profile_path", "packages_manifest", "prepare_script", "build_script"):
            path = ROOT / active[key]
            self.assertTrue(path.exists(), str(path))
            self.assertTrue(path.resolve().is_relative_to(ROOT.resolve()))
        self.assertEqual(active["build_executed"], False)
        for other in self.spec["editions"]:
            if other is active:
                continue
            self.assertIn(other["status"], ("planned", "research-only"))
            for key in ("profile_path", "packages_manifest", "prepare_script", "build_script"):
                self.assertIsNone(other[key], (other["id"], key))

    def test_layers_exist_and_research_lanes_are_isolated(self):
        layers = {entry["id"]: entry for entry in self.spec["layers"]}
        self.assertEqual(len(layers), len(self.spec["layers"]))
        for name, layer in layers.items():
            self.assertTrue(SAFE_ID.fullmatch(name))
            if layer["repo_path"] is not None:
                self.assertTrue((ROOT / layer["repo_path"]).exists(), name)
        for edition in self.spec["editions"]:
            self.assertTrue(edition["layers"])
            self.assertTrue(set(edition["layers"]) <= set(layers))
            if edition["platform"] == "intel-non-t2":
                self.assertNotIn("asahi-platform", edition["layers"])
                self.assertNotIn("t2-support", edition["layers"])
            elif edition["platform"] == "intel-t2":
                self.assertIn("t2-support", edition["layers"])
            else:
                self.assertEqual(edition["platform"], "apple-silicon")
                self.assertIn("asahi-platform", edition["layers"])

    def test_package_and_safety_policy(self):
        policy = self.spec["package_policy"]
        self.assertEqual(policy["default_source"], "official-signed-arch-repositories")
        for key in ("unattended_internal_disk_writes", "automated_firmware_extraction",
                    "default_remote_credentials"):
            self.assertIs(policy[key], False)
        manifest = ROOT / "profiles/mac-intel/packages.x86_64"
        packages = []
        for line in manifest.read_text(encoding="utf-8").splitlines():
            token = line.split("#", 1)[0].strip()
            if token:
                self.assertRegex(token, r"^[a-zA-Z0-9@._+:-]+$")
                packages.append(token)
        self.assertEqual(len(packages), len(set(packages)))
        self.assertIn("intel-ucode", packages)
        self.assertIn("linux-firmware", packages)


if __name__ == "__main__":
    unittest.main()
