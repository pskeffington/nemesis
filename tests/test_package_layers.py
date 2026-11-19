"""Source-only package composition policy tests for Nemesis F02."""

import json
import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


def read_json(name):
    return json.loads((ROOT / name).read_text(encoding="utf-8"))


class PackageLayerContractTests(unittest.TestCase):
    def setUp(self):
        self.package = read_json("spec/package-layers.json")
        self.editions = read_json("spec/editions.json")
        self.layers = {layer["id"]: layer for layer in self.package["layers"]}

    def test_source_only_and_signing(self):
        self.assertEqual(self.package["contract_version"], 1)
        self.assertEqual(self.package["mode"], "repo-foundation")
        self.assertIs(self.package["applied_by_builder"], False)
        self.assertIs(self.package["default_release_enabled"], False)
        self.assertEqual(self.package["default_package_source"], "official-signed-arch")
        policy = self.package["composition_policy"]
        for key in ("signed_repositories_required", "do_not_modify_upstream_profile"):
            self.assertIs(policy[key], True)
        for key in ("AUR_in_core", "auto_enable_hardware_drivers", "automatic_firmware_extraction"):
            self.assertIs(policy[key], False)
        self.assertEqual(self.package["unreviewed_exceptions"], [])

    def test_layer_ids_match_edition_contract(self):
        ids = [layer["id"] for layer in self.package["layers"]]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertEqual(set(ids), {layer["id"] for layer in self.editions["layers"]})
        self.assertEqual(self.package["implemented_merge"]["profile"], "mac-intel")

    def test_dag_and_order(self):
        visited = set()
        active = set()

        def visit(layer_id):
            self.assertNotIn(layer_id, active, f"cycle: {layer_id}")
            if layer_id in visited:
                return
            active.add(layer_id)
            layer = self.layers[layer_id]
            self.assertIsInstance(layer["order"], int)
            for requirement in layer["depends_on"]:
                self.assertIn(requirement, self.layers)
                self.assertLess(self.layers[requirement]["order"], layer["order"],
                                f"order violation for {layer_id}")
                visit(requirement)
            active.remove(layer_id)
            visited.add(layer_id)

        for ident in self.layers:
            visit(ident)
        self.assertEqual(len(visited), len(self.layers))

    def test_manifest_files_and_planned_isolation(self):
        for layer in self.package["layers"]:
            status = layer["status"]
            manifest = layer["manifest"]
            if status == "scaffold-committed":
                self.assertEqual(layer["origin"], "official-arch-delta")
                self.assertIsNotNone(manifest)
                self.assertTrue((ROOT / manifest).is_file())
            else:
                self.assertIsNone(manifest, layer["id"])
            if status in ("design-only", "research-only"):
                self.assertIs(layer["optional"], True)
                self.assertIs(layer["selected_in_active_scaffold"], False)
        script = ROOT / self.package["implemented_merge"]["current_script"]
        self.assertTrue(script.is_file())
        self.assertIs(self.package["implemented_merge"]["future_resolver_authorized"], False)

    def test_platform_exclusions_and_active_edition(self):
        exclusions = self.package["platform_exclusions"]
        platforms = {item["id"] for item in self.editions["platforms"]}
        self.assertEqual(set(exclusions), platforms)
        for edition in self.editions["editions"]:
            names = set(edition["layers"])
            self.assertFalse(names.intersection(exclusions[edition["platform"]]), edition["id"])
            self.assertTrue(names.issubset(self.layers), edition["id"])
        active = next(item for item in self.editions["editions"] if item["id"] == "mac-intel")
        actual_selected = {
            layer["id"] for layer in self.package["layers"]
            if layer["selected_in_active_scaffold"]
        }
        self.assertEqual(actual_selected, set(active["layers"]))
        self.assertEqual(actual_selected, {"arch-releng", "intel-hardware-overlay"})

    def test_conflict_policy_is_fail_closed(self):
        policy = self.package["composition_policy"]
        self.assertEqual(policy["ordering"], "upstream-first-then-layer-order")
        self.assertEqual(policy["duplicates"], "deduplicate-exact-package-name")
        self.assertEqual(policy["unknown_upstream_overlaps"], "resolved-at-profile-staging-only")
        self.assertEqual(policy["declared_conflicts"], "fail-closed-requires-adjudication")
        self.assertEqual(policy["optional_layers"], "excluded-from-intel-live-by-default")
        self.assertIn("upstream-package-order-preserved",
                      self.package["implemented_merge"]["accepted_semantics"])


if __name__ == "__main__":
    unittest.main()
