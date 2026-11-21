#!/usr/bin/env python3
"""Reversible, per-user Nemesis theme staging for Garuda Dr460nized/Plasma 6.

Never edits /etc, /usr, package state, global themes, or panel layouts.
"""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import fcntl
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
STYLE = "Nemesis"

SOURCES = {
    "color-schemes/Nemesis.colors": ROOT / "brand/theme/kde/Nemesis.colors",
    "konsole/Nemesis.colorscheme": ROOT / "brand/theme/konsole/Nemesis.colorscheme",
    "plasma/desktoptheme/Nemesis/metadata.json": ROOT / "brand/theme/plasma/Nemesis/metadata.json",
    "plasma/desktoptheme/Nemesis/colors": ROOT / "brand/theme/plasma/Nemesis/colors",
    "plasma/desktoptheme/Nemesis/plasmarc": ROOT / "brand/theme/plasma/Nemesis/plasmarc",
    "icons/hicolor/scalable/apps/nemesis.svg": ROOT / "brand/identity/nemesis_emblem.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/metadata.json": ROOT / "brand/plasmoid/org.nemesis.themecontrols/metadata.json",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/ui/main.qml": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/ui/main.qml",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/ui/ModeBoard.qml": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/ui/ModeBoard.qml",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/ui/IconTile.qml": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/ui/IconTile.qml",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/terminal.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/terminal.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/radio.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/radio.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/database.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/database.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/location.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/location.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/drone.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/drone.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/satellite.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/satellite.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/headphones.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/headphones.svg",
    "plasma/plasmoids/org.nemesis.themecontrols/contents/images/shield.svg": ROOT / "brand/plasmoid/org.nemesis.themecontrols/contents/images/shield.svg",
    "icons/hicolor/scalable/apps/nemesis-terminal.svg": ROOT / "brand/icons/terminal.svg",
    "icons/hicolor/scalable/apps/nemesis-radio.svg": ROOT / "brand/icons/radio.svg",
    "icons/hicolor/scalable/apps/nemesis-database.svg": ROOT / "brand/icons/database.svg",
    "icons/hicolor/scalable/apps/nemesis-location.svg": ROOT / "brand/icons/location.svg",
    "icons/hicolor/scalable/apps/nemesis-drone.svg": ROOT / "brand/icons/drone.svg",
    "icons/hicolor/scalable/apps/nemesis-satellite.svg": ROOT / "brand/icons/satellite.svg",
    "icons/hicolor/scalable/apps/nemesis-headphones.svg": ROOT / "brand/icons/headphones.svg",
    "icons/hicolor/scalable/apps/nemesis-shield.svg": ROOT / "brand/icons/shield.svg",
    "wallpapers/Nemesis/signal-dusk.svg": ROOT / "brand/wallpapers/signal-dusk.svg",
}
WALLPAPER_KEY = "wallpapers/Nemesis/signal-dusk-3840x2160.png"
ALLOWED_FILES = set(SOURCES) | {WALLPAPER_KEY}


def require_safe_target(target: Path) -> None:
    """Reject symlink redirection inside the theme installation tree."""
    if not DATA.is_absolute() or not STATE_DIR.is_absolute() or not CONFIG.is_absolute():
        raise RuntimeError("XDG paths must be absolute")
    if DATA.is_symlink():
        raise RuntimeError(f"Refusing symlink data directory: {DATA}")
    current = DATA
    for component in target.relative_to(DATA).parts:
        current = current / component
        if current.is_symlink():
            raise RuntimeError(f"Refusing symlink in managed path: {current}")
        if current != target and current.exists() and not current.is_dir():
            raise RuntimeError(f"Refusing non-directory in managed path: {current}")


@contextmanager
def exclusive_install_lock():
    """Serialize mutations so two terminal sessions cannot corrupt ownership state."""
    if STATE_DIR.is_symlink() or MANIFEST.is_symlink():
        raise RuntimeError("State directory/file must not be a symlink")
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    lockfile = STATE_DIR / ".lock"
    flags = os.O_RDWR | os.O_CREAT | getattr(os, "O_NOFOLLOW", 0)
    fd = os.open(lockfile, flags, 0o600)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX)
        yield
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)
        os.close(fd)



def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            h.update(block)
    return h.hexdigest()


def load_state() -> dict:
    if MANIFEST.is_symlink() or STATE_DIR.is_symlink():
        raise RuntimeError("State location is a symlink; refusing access")
    if not MANIFEST.exists():
        return {"schema": 1, "managed": {}, "previous_scheme": None,
                "applied": False, "previous_style": None, "style_applied": False}
    with MANIFEST.open(encoding="utf-8") as stream:
        state = json.load(stream)
    if state.get("schema") != 1 or not isinstance(state.get("managed"), dict):
        raise RuntimeError("Unknown or invalid state format; refusing changes")
    for name, sha in state["managed"].items():
        if name not in ALLOWED_FILES or not isinstance(sha, str) or len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha):
            raise RuntimeError("Invalid or unexpected managed filename/hash in state")
    state.setdefault("previous_style", None)
    state.setdefault("style_applied", False)
    if not isinstance(state["applied"], bool) or not isinstance(state["style_applied"], bool):
        raise RuntimeError("Invalid applied flags in state")
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


def config_value(path: Path, group: str, key: str) -> str:
    if not path.is_file():
        return ""
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.optionxform = str
    try:
        cfg.read(path, encoding="utf-8")
        return cfg.get(group, key, fallback="").strip()
    except (configparser.Error, UnicodeError):
        return ""


def current_scheme() -> str:
    return config_value(CONFIG / "kdeglobals", "General", "ColorScheme")


def current_style() -> str:
    return config_value(CONFIG / "plasmarc", "Theme", "name")


def has_active_wallpaper() -> bool:
    """Prevent orphaning an active wallpaper selected in Plasma settings."""
    path = CONFIG / "plasma-org.kde.plasma.desktop-appletsrc"
    if not path.is_file():
        return False
    data = path.read_text(encoding="utf-8", errors="replace")
    return "signal-dusk-3840x2160.png" in data or "wallpapers/Nemesis/signal-dusk.svg" in data


def has_active_plasmoid() -> bool:
    """Protect an applet still selected on the user's Plasma desktop/panel."""
    path = CONFIG / "plasma-org.kde.plasma.desktop-appletsrc"
    if not path.is_file():
        return False
    return "org.nemesis.themecontrols" in path.read_text(encoding="utf-8", errors="replace")


def has_active_konsole_scheme() -> bool:
    """Check user Konsole profiles before deleting an in-use color preset."""
    for location in [DATA / "konsole", CONFIG / "konsole"]:
        if location.is_dir():
            for profile in location.glob("*.profile"):
                if config_value(profile, "Appearance", "ColorScheme") == SCHEME:
                    return True
    return False


def preflight(source_map: dict[str, Path], state: dict) -> None:
    if not DATA.is_absolute() or not STATE_DIR.is_absolute():
        raise RuntimeError("XDG_DATA_HOME and XDG_STATE_HOME must be absolute paths")
    for relpath, source in source_map.items():
        if not source.is_file():
            raise RuntimeError(f"Source missing: {source}")
        target = DATA / relpath
        require_safe_target(target)
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
    if state.get("applied"):
        if previous == SCHEME:
            print("Nemesis colors already applied by this installer")
            return
        raise RuntimeError("KDE colors changed since Nemesis apply; run restore first to preserve original recovery target")
    if previous == SCHEME:
        raise RuntimeError("Nemesis already active but no reversible previous scheme recorded")
    preflight(SOURCES, state)
    stage_files(SOURCES, state)
    state["previous_scheme"] = previous
    state["applied"] = True
    write_state(state)  # Persist recovery info before external application.
    try:
        subprocess.run(["plasma-apply-colorscheme", SCHEME], check=True)
    except subprocess.CalledProcessError as error:
        # Some command failures happen after the KDE color change was written.
        # Preserve saved recovery info if the new scheme is now active.
        if current_scheme() != SCHEME:
            state["previous_scheme"] = None
            state["applied"] = False
            write_state(state)
        raise RuntimeError("Color apply command failed; inspect status and use restore if Nemesis is active") from error
    print(f"Color scheme applied. Saved previous scheme: {previous}")
    print("Garuda Kvantum may override some accent colors; panel layout and global theme were not touched.")


def apply_style() -> None:
    """Explicit opt-in: switch Plasma *Style* without touching the global theme."""
    require_user()
    if "KDE" not in os.environ.get("XDG_CURRENT_DESKTOP", "").upper() and not os.environ.get("KDE_FULL_SESSION"):
        raise RuntimeError("Apply a Plasma Style only inside a KDE session")
    if not shutil.which("plasma-apply-desktoptheme"):
        raise RuntimeError("plasma-apply-desktoptheme missing; choose the style in System Settings")
    previous = current_style()
    if not previous:
        raise RuntimeError("Previous Plasma Style unavailable; select Nemesis manually instead")
    state = load_state()
    if state["style_applied"]:
        if previous == STYLE:
            print("Nemesis Plasma Style already applied")
            return
        raise RuntimeError("Plasma Style changed after Nemesis apply; run restore-style before retrying")
    if previous == STYLE:
        raise RuntimeError("Nemesis style already active; no saved previous style")
    stage_files(SOURCES, state)
    state["previous_style"] = previous
    state["style_applied"] = True
    write_state(state)
    try:
        subprocess.run(["plasma-apply-desktoptheme", STYLE], check=True)
    except subprocess.CalledProcessError as error:
        if current_style() != STYLE:
            state["previous_style"] = None
            state["style_applied"] = False
            write_state(state)
        raise RuntimeError("Plasma Style apply failed; inspect status then use restore-style") from error
    print(f"Plasma Style applied; original style recorded: {previous}")
    print("Global Theme, panel layout, Kvantum and Garuda configuration remain unchanged")


def restore_style(state: dict | None = None) -> None:
    require_user()
    state = state or load_state()
    previous = state.get("previous_style")
    if not state.get("style_applied") or not previous:
        print("No installer-applied Plasma Style recorded")
        return
    active = current_style()
    if not active:
        raise RuntimeError("Cannot identify active Plasma Style; restore manually in System Settings before uninstalling")
    if active == STYLE:
        if not shutil.which("plasma-apply-desktoptheme"):
            raise RuntimeError("Cannot restore Plasma Style: plasma-apply-desktoptheme unavailable")
        subprocess.run(["plasma-apply-desktoptheme", previous], check=True)
        print(f"Restored Plasma Style: {previous}")
    else:
        print(f"Plasma Style changed independently ({active}); leaving it untouched")
    state["previous_style"] = None
    state["style_applied"] = False
    write_state(state)


def restore(state: dict | None = None) -> None:
    require_user()
    state = state or load_state()
    previous = state.get("previous_scheme")
    if not state.get("applied") or not previous:
        print("No installer-applied color scheme recorded; nothing to restore")
        return
    active = current_scheme()
    if not active:
        raise RuntimeError("Cannot identify active KDE colors; restore manually in System Settings before uninstalling")
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
        require_safe_target(target)
        if target.exists() and digest(target) != known_hash:
            raise RuntimeError(f"Refusing to remove modified file: {target}")
    if current_style() == STYLE and not state.get("style_applied"):
        raise RuntimeError("Nemesis Plasma Style is active without a recorded backup; switch to your prior style first")
    if has_active_plasmoid():
        raise RuntimeError("Nemesis Theme Inspector is active; remove it from desktop/panel before uninstall")
    if has_active_wallpaper():
        raise RuntimeError("Nemesis wallpaper is selected; choose another wallpaper before uninstall")
    if has_active_konsole_scheme():
        raise RuntimeError("Nemesis is selected by a Konsole profile; change its Appearance setting first")
    if state.get("style_applied"):
        restore_style(state)
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
    source = SOURCES["wallpapers/Nemesis/signal-dusk.svg"]
    dest = DATA / WALLPAPER_KEY
    require_safe_target(dest)
    prior = state["managed"].get(WALLPAPER_KEY)
    if dest.exists() and (not prior or digest(dest) != prior):
        raise RuntimeError(f"Refusing unowned or modified wallpaper: {dest}")
    # Reject output collisions before installing any new assets.
    stage_files(SOURCES, state)
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
    print(f"Active Plasma Style: {current_style() or 'unknown'}")
    print(f"Managed assets: {len(state['managed'])}")
    for relpath, known_hash in sorted(state["managed"].items()):
        target = DATA / relpath
        status_label = "OK" if target.is_file() and not target.is_symlink() and digest(target) == known_hash else "MODIFIED_OR_MISSING"
        print(f"  {status_label:20} {target}")
    print(f"Installer-applied: {state.get('applied', False)}")
    print(f"Saved previous scheme: {state.get('previous_scheme') or 'none'}")
    print(f"Installer-applied style: {state.get('style_applied', False)}")
    print(f"Saved previous style: {state.get('previous_style') or 'none'}")


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
    print("Apply switches only KDE colors; apply-style is a separate opt-in. Global theme, panels, Kvantum and login graphics are not modified")


def doctor() -> None:
    """Read-only compatibility diagnostics without usernames or machine identifiers."""
    state = load_state()
    desktop = os.environ.get("XDG_CURRENT_DESKTOP", "unknown")
    session = os.environ.get("XDG_SESSION_TYPE", "unknown")
    plasma = "KDE" in desktop.upper() or bool(os.environ.get("KDE_FULL_SESSION"))
    print(f"Desktop: {desktop} | session: {session}")
    print(f"Plasma session: {'YES' if plasma else 'NO (apply unavailable)'}")
    for tool in ("plasma-apply-colorscheme", "plasma-apply-desktoptheme", "rsvg-convert"):
        print(f"{tool}: {'AVAILABLE' if shutil.which(tool) else 'MISSING (optional for relevant command)'}")
    print(f"KDE color: {current_scheme() or 'unknown'} | Plasma Style: {current_style() or 'unknown'}")
    print(f"Owned files: {len(state['managed'])} | colors applied: {state.get('applied')} | style applied: {state.get('style_applied')}")
    print(f"Plasma wallpaper using Nemesis: {has_active_wallpaper()}")
    print(f"Plasma widget using Nemesis: {has_active_plasmoid()}")
    print(f"Konsole profile using Nemesis: {has_active_konsole_scheme()}")
    problems = []
    for relpath, src in SOURCES.items():
        target = DATA / relpath
        try:
            require_safe_target(target)
        except RuntimeError as err:
            problems.append(str(err))
            continue
        if not src.is_file():
            problems.append(f"Source missing: {src.name}")
        if target.exists() and relpath not in state['managed']:
            problems.append(f"Unowned filename collision: {relpath}")
        if target.is_file() and relpath in state['managed'] and digest(target) != state['managed'][relpath]:
            problems.append(f"Edited managed file: {relpath}")
    for problem in problems:
        print(f"BLOCK: {problem}")
    if not problems:
        print("Asset preflight: OK")
    print("Garuda's Kvantum may reset the accent after relogin; test both sessions")
    print("No system files or desktop settings were changed")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["plan", "doctor", "install", "apply", "apply-style", "restore", "restore-style", "uninstall", "render-wallpaper", "status"])
    action = parser.parse_args().action
    actions = {"plan": plan, "doctor": doctor, "install": stage, "apply": apply,
               "apply-style": apply_style, "restore": restore, "restore-style": restore_style,
               "uninstall": uninstall, "render-wallpaper": render_wallpaper, "status": status}
    try:
        if action in ("install", "apply", "apply-style", "restore", "restore-style", "uninstall", "render-wallpaper"):
            require_user()
            with exclusive_install_lock():
                actions[action]()
        else:
            actions[action]()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as err:
        print(f"Nemesis error: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
