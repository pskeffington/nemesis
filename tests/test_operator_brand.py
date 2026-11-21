"""Source and accessibility contracts for the optional Nemesis Plasma 6 widget."""

import json
from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / "brand"
WIDGET = BRAND / "plasmoid/org.nemesis.themecontrols"
ICON_NAMES = (
    "terminal", "radio", "database", "location",
    "drone", "satellite", "headphones", "shield",
)

def brightness(channel: str) -> float:
    value = int(channel, 16) / 255
    return value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4

def contrast(a: str, b: str) -> float:
    aa = [brightness(a[i:i+2]) for i in (1, 3, 5)]
    bb = [brightness(b[i:i+2]) for i in (1, 3, 5)]
    la = aa[0] * 0.2126 + aa[1] * 0.7152 + aa[2] * 0.0722
    lb = bb[0] * 0.2126 + bb[1] * 0.7152 + bb[2] * 0.0722
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)

class NemesisInteractiveContracts(unittest.TestCase):
    def test_qml_is_plasma6_widget_with_unique_identity(self):
        metadata = json.loads((WIDGET / "metadata.json").read_text())
        self.assertEqual(metadata["KPackageStructure"], "Plasma/Applet")
        self.assertEqual(metadata["X-Plasma-API-Minimum-Version"], "6.0")
        self.assertEqual(metadata["KPlugin"]["Id"], "org.nemesis.themecontrols")
        self.assertNotIn("X-Plasma-MainScript", metadata)
        self.assertNotIn("X-Plasma-API", metadata)
        entry = (WIDGET / "contents/ui/main.qml").read_text()
        self.assertIn("PlasmoidItem {", entry)
        self.assertIn("fullRepresentation: ModeBoard", entry)

    def test_all_eight_original_svg_icons_mirrored_exactly(self):
        for name in ICON_NAMES:
            with self.subTest(icon=name):
                original = (BRAND / "icons" / f"{name}.svg").read_bytes()
                bundled = (WIDGET / "contents/images" / f"{name}.svg").read_bytes()
                self.assertEqual(original, bundled)
                xml = ET.fromstring(bundled)
                self.assertTrue(xml.tag.endswith("svg"))
                self.assertEqual(xml.attrib.get("viewBox"), "0 0 64 64")

    def test_token_color_readability(self):
        tokens = json.loads((BRAND / "identity/tokens.json").read_text())["colors"]
        self.assertGreaterEqual(contrast(tokens["text_high"], tokens["background"]), 4.5)
        self.assertGreaterEqual(contrast(tokens["text_muted"], tokens["background"]), 4.5)
        for state in ("primary", "accent"):
            self.assertGreaterEqual(contrast(tokens[state], tokens["background"]), 3)
        tile = (WIDGET / "contents/ui/IconTile.qml").read_text()
        board = (WIDGET / "contents/ui/ModeBoard.qml").read_text()
        self.assertIn(tokens["primary"], board)
        self.assertIn(tokens["accent"], board)
        self.assertIn(tokens["text_high"], tile)

    def test_action_semantics_use_accessible_qt_controls(self):
        tile = (WIDGET / "contents/ui/IconTile.qml").read_text()
        board = (WIDGET / "contents/ui/ModeBoard.qml").read_text()
        self.assertIn("Controls.Button {", tile)
        self.assertIn("focusPolicy: Qt.StrongFocus", tile)
        self.assertIn("hoverEnabled: true", tile)
        self.assertIn("onClicked: activated(channelKey)", tile)
        self.assertIn("Accessible.name:", tile)
        self.assertIn("tile.activeFocus", tile)
        self.assertIn("tile.down", tile)
        self.assertIn("selected: board.selectedKey === channelKey", board)
        self.assertIn("onActivated: key => board.selectChannel(key)", board)
        self.assertIn("onToggled: board.useCyan = checked", board)
        self.assertIn("onToggled: board.highContrast = checked", board)
        self.assertIn("onClicked: board.resetPreview()", board)

    def test_widget_has_no_implicit_device_or_shell_actions(self):
        for name in ("main.qml", "ModeBoard.qml", "IconTile.qml"):
            qml = (WIDGET / "contents/ui" / name).read_text()
            for forbidden in ("Qt.openUrlExternally", "XMLHttpRequest", "Process {", "system(", "exec(", "D-Bus", "network.send"):
                with self.subTest(file=name, forbidden=forbidden):
                    self.assertNotIn(forbidden, qml)

    def test_opt_in_kde_defaults_and_live_launcher_mapping(self):
        stage = (ROOT / "scripts/stage-operator-brand.sh").read_text()
        prepare = (ROOT / "scripts/prepare-operator-profile.sh").read_text()
        config = (BRAND / "operator-defaults/plasmarc").read_text()
        konsole = (BRAND / "operator-defaults/konsolerc").read_text()
        profile = (BRAND / "operator-defaults/Nemesis.profile").read_text()
        metadata = json.loads((BRAND / "theme/plasma/Nemesis/metadata.json").read_text())
        self.assertEqual(metadata["KPackageStructure"], "Plasma/Theme")
        self.assertIn("DefaultProfile=Nemesis.profile", konsole)
        self.assertIn("ColorScheme=Nemesis", profile)
        self.assertIn("name=Nemesis", config)
        self.assertIn("etc/xdg/kdeglobals", stage)
        self.assertIn("etc/xdg/plasmarc", stage)
        self.assertIn("etc/xdg/konsolerc", stage)
        self.assertIn("Icon=nemesis-location", stage)
        self.assertIn("Icon=nemesis-shield", stage)
        self.assertIn("NEMESIS_OPERATOR_BRAND", prepare)
        self.assertIn("stage-operator-brand.sh", prepare)
        self.assertNotIn("stage-operator-brand.sh", (ROOT / "scripts/prepare-air-field-profile.sh").read_text())
        self.assertNotIn("stage-operator-brand.sh", (ROOT / "scripts/prepare-profile.sh").read_text())

    def test_image_decode_state_is_exercised_in_real_qt(self):
        tile = (WIDGET / "contents/ui/IconTile.qml").read_text()
        qml = (ROOT / "tests/qml/tst_theme_board.qml").read_text()
        self.assertIn("iconStatus: objectIcon.status", tile)
        self.assertIn("tryCompare(tile, \"iconStatus\", Image.Ready)", qml)

if __name__ == "__main__":
    unittest.main()
