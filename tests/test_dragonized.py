"""Fixture-only tests: no actual Garuda/KDE session is modified."""
from pathlib import Path
import json
import os
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
CLI = ROOT / 'brand/scripts/dragonized.py'

class DragonizedDeployTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.top = Path(self.tmp.name)
        self.data = self.top / 'share'
        self.state = self.top / 'state'
        self.config = self.top / 'config'
        self.config.mkdir()
        self.env = dict(os.environ, XDG_DATA_HOME=str(self.data), XDG_STATE_HOME=str(self.state), XDG_CONFIG_HOME=str(self.config))

    def run_cli(self, action, ok=True):
        p = subprocess.run([sys.executable, str(CLI), action], env=self.env, text=True, capture_output=True)
        if ok:
            self.assertEqual(p.returncode, 0, p.stderr)
        else:
            self.assertNotEqual(p.returncode, 0, p.stdout)
        return p

    def test_plan_is_read_only(self):
        self.run_cli('plan')
        self.assertFalse(self.data.exists())
        self.assertFalse(self.state.exists())

    def test_install_idempotent_and_uninstall(self):
        self.run_cli('install')
        self.assertTrue((self.data/'color-schemes/Nemesis.colors').is_file())
        self.assertTrue((self.data/'plasma/desktoptheme/Nemesis/metadata.json').is_file())
        self.assertTrue((self.data/'wallpapers/Nemesis/signal-dusk.svg').is_file())
        self.run_cli('install')
        self.assertIn('Managed assets: 27', self.run_cli('status').stdout)
        self.run_cli('uninstall')
        self.assertFalse((self.data/'color-schemes/Nemesis.colors').exists())

    def test_collision_is_blocked_without_partial_install(self):
        target = self.data/'konsole/Nemesis.colorscheme'
        target.parent.mkdir(parents=True)
        target.write_text('user file')
        self.run_cli('install', ok=False)
        self.assertEqual(target.read_text(), 'user file')
        self.assertFalse((self.data/'color-schemes/Nemesis.colors').exists())

    def test_modified_file_is_never_deleted(self):
        self.run_cli('install')
        target = self.data/'color-schemes/Nemesis.colors'
        target.write_text('user-changed')
        self.run_cli('uninstall', ok=False)
        self.assertEqual(target.read_text(), 'user-changed')

    def test_apply_and_restore_previous_kde_colors(self):
        self.env['XDG_CURRENT_DESKTOP'] = 'KDE'
        cfg = self.config/'kdeglobals'
        cfg.write_text('[General]\nColorScheme=Dr460nized\n')
        bindir = self.top/'bin'; bindir.mkdir()
        tool = bindir/'plasma-apply-colorscheme'
        tool.write_text('#!/usr/bin/env python3\nimport os,sys\nfrom pathlib import Path\np=Path(os.environ["XDG_CONFIG_HOME"])/"kdeglobals"\np.write_text("[General]\\nColorScheme="+sys.argv[1]+"\\n")\n')
        tool.chmod(0o755)
        self.env['PATH'] = str(bindir)+os.pathsep+self.env['PATH']
        self.run_cli('apply')
        self.assertIn('ColorScheme=Nemesis', cfg.read_text())
        self.run_cli('restore')
        self.assertIn('ColorScheme=Dr460nized', cfg.read_text())
        self.run_cli('uninstall')
        self.assertTrue(cfg.exists())

if __name__ == '__main__':
    unittest.main()


class DragonizedOperabilityTests(unittest.TestCase):
    """Risk-focused simulated session tests: never change real Plasma settings."""
    setUp = DragonizedDeployTests.setUp
    run_cli = DragonizedDeployTests.run_cli

    def tool(self, name, filename, group, key, fail=False):
        bindir = self.top / 'bin'
        bindir.mkdir(exist_ok=True)
        executable = bindir / name
        prefix = f"[{group}]\n{key}="
        executable.write_text(
            '#!/usr/bin/env python3\n'
            'import os, sys\n'
            'from pathlib import Path\n'
            f'p = Path(os.environ["XDG_CONFIG_HOME"]) / {filename!r}\n'
            f'p.write_text({prefix!r} + sys.argv[1] + "\\n")\n'
            f'sys.exit({1 if fail else 0})\n'
        )
        executable.chmod(0o755)
        self.env['PATH'] = str(bindir) + os.pathsep + self.env['PATH']
        self.env['XDG_CURRENT_DESKTOP'] = 'KDE'
        return executable

    def test_doctor_is_read_only(self):
        result = self.run_cli('doctor')
        self.assertIn('Asset preflight: OK', result.stdout)
        self.assertFalse(self.data.exists())
        self.assertFalse(self.state.exists())

    def test_reject_tampered_manifest_path(self):
        self.state.joinpath('nemesis-theme').mkdir(parents=True)
        state = self.state / 'nemesis-theme/state.json'
        state.write_text(json.dumps({'schema': 1, 'managed': {'../../outside': '0' * 64}, 'applied': False}))
        self.run_cli('uninstall', ok=False)
        self.assertIn('../../outside', state.read_text())

    def test_block_symlink_intermediate_directory(self):
        outside = self.top / 'outside'
        outside.mkdir()
        self.data.mkdir()
        (self.data / 'color-schemes').symlink_to(outside, target_is_directory=True)
        self.run_cli('install', ok=False)
        self.assertEqual(list(outside.iterdir()), [])

    def test_preserve_original_color_on_external_drift(self):
        config = self.config / 'kdeglobals'
        config.write_text('[General]\nColorScheme=Dr460nized\n')
        self.tool('plasma-apply-colorscheme', 'kdeglobals', 'General', 'ColorScheme')
        self.run_cli('apply')
        config.write_text('[General]\nColorScheme=Sweet\n')
        self.run_cli('apply', ok=False)
        state = json.loads((self.state/'nemesis-theme/state.json').read_text())
        self.assertEqual(state['previous_scheme'], 'Dr460nized')
        self.run_cli('restore')
        self.assertIn('ColorScheme=Sweet', config.read_text())

    def test_failed_color_command_after_change_preserves_recovery(self):
        config = self.config / 'kdeglobals'
        config.write_text('[General]\nColorScheme=Dr460nized\n')
        stub = self.tool('plasma-apply-colorscheme', 'kdeglobals', 'General', 'ColorScheme', fail=True)
        self.run_cli('apply', ok=False)
        state = json.loads((self.state / 'nemesis-theme/state.json').read_text())
        self.assertTrue(state['applied'])
        self.assertEqual(state['previous_scheme'], 'Dr460nized')
        # Replacing the failing mock with a successful one is simulated recovery.
        stub.write_text(stub.read_text().replace('sys.exit(1)', 'sys.exit(0)'))
        self.run_cli('restore')
        self.assertIn('ColorScheme=Dr460nized', config.read_text())

    def test_style_roundtrip_is_independent_of_colors(self):
        style = self.config / 'plasmarc'
        style.write_text('[Theme]\nname=Dr460nized\n')
        self.tool('plasma-apply-desktoptheme', 'plasmarc', 'Theme', 'name')
        self.run_cli('apply-style')
        self.assertIn('name=Nemesis', style.read_text())
        self.run_cli('restore-style')
        self.assertIn('name=Dr460nized', style.read_text())
        self.run_cli('uninstall')
        self.assertEqual(json.loads((self.state/'nemesis-theme/state.json').read_text())['managed'], {})

    def test_manually_selected_style_blocks_uninstall(self):
        self.run_cli('install')
        style = self.config/'plasmarc'
        style.write_text('[Theme]\nname=Nemesis\n')
        self.run_cli('uninstall', ok=False)
        self.assertTrue((self.data/'plasma/desktoptheme/Nemesis/metadata.json').exists())
        style.write_text('[Theme]\nname=Dr460nized\n')
        self.run_cli('uninstall')

    def test_selected_wallpaper_blocks_uninstall(self):
        self.run_cli('install')
        config = self.config/'plasma-org.kde.plasma.desktop-appletsrc'
        config.write_text('[Containments][1]\nImage=file:///home/example/.local/share/wallpapers/Nemesis/signal-dusk-3840x2160.png\n')
        self.run_cli('uninstall', ok=False)
        self.assertTrue((self.data/'wallpapers/Nemesis/signal-dusk.svg').is_file())
        config.unlink()
        self.run_cli('uninstall')


    def test_selected_plasmoid_blocks_uninstall(self):
        self.run_cli('install')
        config = self.config/'plasma-org.kde.plasma.desktop-appletsrc'
        config.write_text('[Containments][1][Applets][2]\nplugin=org.nemesis.themecontrols\n')
        self.run_cli('uninstall', ok=False)
        self.assertTrue((self.data/'plasma/plasmoids/org.nemesis.themecontrols/metadata.json').exists())
        config.unlink()
        self.run_cli('uninstall')

    def test_selected_konsole_profile_blocks_uninstall(self):
        self.run_cli('install')
        profile_dir = self.data/'konsole'
        (profile_dir/'User.profile').write_text('[Appearance]\nColorScheme=Nemesis\n')
        self.run_cli('uninstall', ok=False)
        (profile_dir/'User.profile').write_text('[Appearance]\nColorScheme=Sweet\n')
        self.run_cli('uninstall')

    def test_uninstall_restores_style_and_color(self):
        color = self.config/'kdeglobals'
        style = self.config/'plasmarc'
        color.write_text('[General]\nColorScheme=Dr460nized\n')
        style.write_text('[Theme]\nname=Dr460nized\n')
        self.tool('plasma-apply-colorscheme', 'kdeglobals', 'General', 'ColorScheme')
        self.tool('plasma-apply-desktoptheme', 'plasmarc', 'Theme', 'name')
        self.run_cli('apply')
        self.run_cli('apply-style')
        self.run_cli('uninstall')
        self.assertIn('ColorScheme=Dr460nized', color.read_text())
        self.assertIn('name=Dr460nized', style.read_text())
        self.assertFalse((self.data/'color-schemes/Nemesis.colors').exists())

    def test_old_manifest_is_compatible(self):
        self.run_cli('install')
        path = self.state/'nemesis-theme/state.json'
        state = json.loads(path.read_text())
        del state['previous_style']
        del state['style_applied']
        path.write_text(json.dumps(state))
        self.run_cli('status')
        self.run_cli('uninstall')
