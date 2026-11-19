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
        self.assertIn('Managed assets: 7', self.run_cli('status').stdout)
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
