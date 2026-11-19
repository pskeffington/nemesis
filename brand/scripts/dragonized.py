#!/usr/bin/env python3
"""Reversible, per-user Nemesis theme staging for Garuda Dr460nized/Plasma 6.

Never edits /etc, /usr, package state, global themes, or panel layouts.
"""

from __future__ import annotations

import argparse
import configparser
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[2]
DATA = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share").expanduser()
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state").expanduser() / "nemesis-theme"
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config").expanduser()
MANIFEST = STATE_DIR / "state.json"
SCHEME = "Nemesis"

SOURCES = {
    "color-schemes/Nemesis.colors": ROOT / "brand/theme/kde/Nemesis.colors",
    "konsole/Nemesis.colorscheme": ROOT / "brand/theme/konsole/Nemesis.colorscheme",
    "plasma/desktoptheme/Nemesis/metadata.json": ROOT / "brand/theme/plasma/Nemesis/metadata.json",
    "plasma/desktoptheme/Nemesis/colors": ROOT / "brand/theme/plasma/Nemesis/colors",
    "plasma/desktoptheme/Nemesis/plasmarc": ROOT / "brand/theme/plasma/Nemesis/plasmarc",
    "icons/hicolor/scalable/apps/nemesis.svg": ROOT / "brand/identity/nemesis_emblem.svg",
    "wallpapers/Nemesis/signal-dusk.svg": ROOT / "brand/wallpapers/signal-dusk.svg",
}
WALLPAPER_KEY = "wallpapers/Nemesis/signal-dusk-3840x2160.png"


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            h.update(block)
    return h.hexdigest()


def load_state() -> dict:
    if not MANIFEST.exists():
        return {"schema": 1, "managed": {}, "previous_scheme": None, "applied": False}
    with MANIFEST.open(encoding="utf-8") as stream:
        state = json.load(stream)
    if state.get("schema") != 1 or not isinstance(state.get("managed"), dict):
        raise RuntimeError("Unknown or invalid state format; refusing changes")
    return state


def write_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    fd, path = tempfile.mkstemp(prefix="state.", dir=STATE_DIR)
    try:
        os.chmod(path, 0o600)
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(state, stream, indent=2, sort_keys=True)
            stream.write("\n")
        os.replace(path, MANIFEST)
    finally:
        if os.path.exists(path):
            os.unlink(path)


def current_scheme() -> str:
    kdeglobals = CONFIG / "kdeglobals"
    if not kdeglobals.is_file():
        return ""
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.optionxform = str
    try:
        cfg.read(kdeglobals, encoding="utf-8")
        return cfg.get("General", "ColorScheme", fallback="").strip()
    except configparser.Error:
        return ""


def preflight(source_map: dict[str, Path], state: dict) -> None:
    if not DATA.is_absolute() or not STATE_DIR.is_absolute():
        raise RuntimeError("XDG_DATA_HOME and XDG_STATE_HOME must be absolute paths")
    for relpath, source in source_map.items():
        if not source.is_file():
            raise RuntimeError(f"Source missing: {source}")
        target = DATA / relpath
        if target.is_symlink():
            raise RuntimeError(f"Refusing symlink target: {target}")
        if target.exists():
            prior = state["managed"].get(relpath)
            if not prior:
                raise RuntimeError(f"Refusing unowned existing file: {target}")
            if digest(target) != prior:
                raise RuntimeError(f"Refusing modified managed file: {target}")


def stage_files(source_map: dict[str, Path], state: dict) -> None:
    preflight(source_map, state)
    created: list[Path] = []
    try:
        for relpath, source in source_map.items():
            target = DATA / relpath
            if target.exists() and digest(target) == digest(source):
                print(f"UNCHANGED {target}")
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                fd, tmp = tempfile.mkstemp(prefix=".nemesis.", dir=target.parent)
                os.close(fd)
                try:
                    shutil.copyfile(source, tmp)
                    os.chmod(tmp, 0o644)
                    if not target.exists():
                        created.append(target)
                    os.replace(tmp, target)
                finally:
                    if os.path.exists(tmp):
                        os.unlink(tmp)
                print(f"STAGED {target}")
            state["managed"][relpath] = digest(target)
        write_state(state)
    except Exception:
        # Newly created paths are safe to remove if manifest could not be written.
        for path in created:
            if path.is_file():
                path.unlink()
        raise


def require_user() -> None:
    if os.geteuid() == 0:
        raise RuntimeError("Do not run with sudo/root. This installer is per-user only")


def stage() -> None:
    require_user()
    state = load_state()
    stage_files(SOURCES, state)
    print("Installed preview assets only; desktop/global theme was not changed.")


def apply() -> None:
    require_user()
    if "KDE" not in os.environ.get("XDG_CURRENT_DESKTOP", "").upper() and not os.environ.get("KDE_FULL_SESSION"):
        raise RuntimeError("Apply only inside an active KDE Plasma session")
    if not shutil.which("plasma-apply-colorscheme"):
        raise RuntimeError("Plasma colorscheme tool not installed; install plasma-workspace or select the scheme in System Settings")
    previous = current_scheme()
    if not previous:
        raise RuntimeError("Previous color scheme unavailable; install and select Nemesis manually in System Settings")
    state = load_state()
    if state.get("applied") and previous == SCHEME:
        print("Nemesis already applied by this installer")
        return
    if previous == SCHEME:
        raise RuntimeError("Nemesis already active but no reversible previous scheme recorded")
    preflight(SOURCES, state)
    stage_files(SOURCES, state)
    state["previous_scheme"] = previous
    state["applied"] = True
    write_state(state)  # Persist recovery info before external application.
    try:
        subprocess.run(["plasma-apply-colorscheme", SCHEME], check=True)
    except Exception:
        state["previous_scheme"] = None
        state["applied"] = False
        write_state(state)
        raise
    print(f"Color scheme applied. Saved previous scheme: {previous}")
    print("Garuda Kvantum may override some accent colors; panel layout and global theme were not touched.")


def restore(state: dict | None = None) -> None:
    require_user()
    state = state or load_state()
    previous = state.get("previous_scheme")
    if not state.get("applied") or not previous:
        print("No installer-applied color scheme recorded; nothing to restore")
        return
    active = current_scheme()
    if active == SCHEME:
        if not shutil.which("plasma-apply-colorscheme"):
            raise RuntimeError("Cannot restore: plasma-apply-colorscheme is unavailable")
        subprocess.run(["plasma-apply-colorscheme", previous], check=True)
        print(f"Restored previous color scheme: {previous}")
    else:
        print(f"Color scheme has been changed independently ({active or 'unknown'}); leaving it untouched")
    state["previous_scheme"] = None
    state["applied"] = False
    write_state(state)


def uninstall() -> None:
    require_user()
    state = load_state()
    if current_scheme() == SCHEME and not state.get("applied"):
        raise RuntimeError("Nemesis is active without saved previous scheme; switch colors in System Settings first")
    # Fail the whole operation if any managed file was edited since installation.
    for relpath, known_hash in state["managed"].items():
        target = DATA / relpath
        if target.is_symlink() or (target.exists() and digest(target) != known_hash):
            raise RuntimeError(f"Refusing to remove modified file: {target}")
    if state.get("applied"):
        restore(state)
    for relpath in list(state["managed"]):
        target = DATA / relpath
        if target.is_file():
            target.unlink()
            print(f"REMOVED {target}")
        state["managed"].pop(relpath)
    write_state(state)
    print("Nemesis preview files removed; other Garuda settings remain unchanged")


def render_wallpaper() -> None:
    require_user()
    converter = shutil.which("rsvg-convert")
    if not converter:
        raise RuntimeError("Install optional wallpaper converter: sudo pacman -S --needed librsvg")
    state = load_state()
    preflight(SOURCES, state)
    stage_files(SOURCES, state)
    source = SOURCES["wallpapers/Nemesis/signal-dusk.svg"]
    dest = DATA / WALLPAPER_KEY
    prior = state["managed"].get(WALLPAPER_KEY)
    if dest.is_symlink() or (dest.exists() and (not prior or digest(dest) != prior)):
        raise RuntimeError(f"Refusing unowned or modified wallpaper: {dest}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    fd, tempname = tempfile.mkstemp(prefix="nemesis-wallpaper.", suffix=".png", dir=dest.parent)
    os.close(fd)
    try:
        subprocess.run([converter, "-w", "3840", "-h", "2160", "-o", tempname, str(source)], check=True)
        with open(tempname, "rb") as stream:
            header = stream.read(24)
        if header[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack(">II", header[16:24]) != (3840, 2160):
            raise RuntimeError("Wallpaper conversion did not produce a valid 3840x2160 PNG")
        os.chmod(tempname, 0o644)
        os.replace(tempname, dest)
        state["managed"][WALLPAPER_KEY] = digest(dest)
        write_state(state)
    finally:
        if os.path.exists(tempname):
            os.unlink(tempname)
    print(f"RENDERED {dest}")
    print("Select this PNG manually in Plasma Wallpaper settings; existing wallpaper not changed")


def status() -> None:
    state = load_state()
    print(f"User data directory: {DATA}")
    print(f"Active KDE scheme: {current_scheme() or 'unknown'}")
    print(f"Managed assets: {len(state['managed'])}")
    for relpath, known_hash in sorted(state["managed"].items()):
        target = DATA / relpath
        status_label = "OK" if target.is_file() and not target.is_symlink() and digest(target) == known_hash else "MODIFIED_OR_MISSING"
        print(f"  {status_label:20} {target}")
    print(f"Installer-applied: {state.get('applied', False)}")
    print(f"Saved previous scheme: {state.get('previous_scheme') or 'none'}")


def plan() -> None:
    state = load_state()
    print("PLAN ONLY — no writes or desktop changes")
    for relpath, source in SOURCES.items():
        target = DATA / relpath
        if not source.exists():
            action = "SOURCE_MISSING"
        elif target.exists():
            action = "OWNED" if relpath in state["managed"] else "COLLISION"
        else:
            action = "NEW"
        print(f"  {action:14} {source} -> {target}")
    print("Apply affects only the KDE color scheme; Plasma panels, Garuda global look-and-feel, Kvantum and login graphics are not modified")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["plan", "install", "apply", "restore", "uninstall", "render-wallpaper", "status"])
    action = parser.parse_args().action
    actions = {"plan": plan, "install": stage, "apply": apply, "restore": restore, "uninstall": uninstall, "render-wallpaper": render_wallpaper, "status": status}
    try:
        actions[action]()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as err:
        print(f"Nemesis error: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
