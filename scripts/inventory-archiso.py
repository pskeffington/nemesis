#!/usr/bin/env python3
"""Read-only ArchISO baseline inventory: source vs Intel and Air staging."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import subprocess

def packages(path):
    result = []
    for raw in path.read_text().splitlines():
        item = raw.split("#", 1)[0].strip()
        if item and item not in result:
            result.append(item)
    return result

def symlink_state(root, relative):
    target = root / relative
    if target.is_symlink():
        return {"state": "symlink", "target": os.readlink(target)}
    if target.exists():
        return {"state": "present-non-symlink"}
    return {"state": "absent"}

def versions():
    try:
        result = subprocess.run(["pacman", "-Sl"], capture_output=True, text=True, check=True)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return {}
    found = {}
    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) >= 3:
            found.setdefault(fields[1], {"repo": fields[0], "version": fields[2]})
    return found

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--intel", type=Path, required=True)
    parser.add_argument("--air", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    sets = {name: packages(root / "packages.x86_64") for name, root in
            [("upstream", args.source), ("intel", args.intel), ("air", args.air)]}
    upstream, intel, air = map(set, (sets["upstream"], sets["intel"], sets["air"]))
    if not upstream <= intel or not intel <= air:
        raise SystemExit("ERROR: staged packages do not preserve upstream/Intel contents")
    v = versions()
    selected = sorted(air)
    rows = [{"package": name, "upstream": name in upstream, "intel": name in intel,
             "air": name in air, "repo": v.get(name, {}).get("repo"),
             "version": v.get(name, {}).get("version")} for name in selected]
    units = [
        "etc/systemd/system/multi-user.target.wants/sshd.service",
        "etc/systemd/system/multi-user.target.wants/ModemManager.service",
        "etc/systemd/system/dbus-org.freedesktop.ModemManager1.service",
        "etc/systemd/system/ModemManager.service",
        "etc/systemd/system/multi-user.target.wants/NetworkManager.service",
        "etc/systemd/system/multi-user.target.wants/iwd.service",
        "etc/systemd/system/multi-user.target.wants/systemd-networkd.service",
    ]
    service_states = {name: {unit: symlink_state(root / "airootfs", unit) for unit in units}
                      for name, root in [("upstream", args.source), ("intel", args.intel),
                                         ("air", args.air)]}
    profile_hash = hashlib.sha256((args.source / "packages.x86_64").read_bytes()).hexdigest()
    data = {
        "status": "SOURCE_AND_STAGED_PROFILE_ONLY_NOT_RUNTIME_VERIFIED",
        "upstream_manifest_sha256": profile_hash,
        "counts": {"upstream": len(upstream), "intel": len(intel), "air": len(air),
                   "intel_unique_additions": len(intel - upstream),
                   "air_unique_additions": len(air - intel),
                   "metadata_versions_available": sum(r["version"] is not None for r in rows)},
        "intel_additions": sorted(intel - upstream),
        "air_additions": sorted(air - intel),
        "package_metadata": rows,
        "service_links": service_states,
        "limits": ["Pacman repository versions are a current lookup, not a resolved ISO lockfile",
                   "Filesystem symlinks do not establish running service state",
                   "No package install size, bootability, memory or power is measured"]
    }
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "package-inventory.json").write_text(json.dumps(data, indent=2) + "\n")
    with (args.out / "package-inventory.csv").open("w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0]) if rows else
                                ["package", "upstream", "intel", "air", "repo", "version"])
        writer.writeheader()
        writer.writerows(rows)
    report = ["# Nemesis ArchISO package and service inventory", "",
              "Status: staged profile inspection, NOT runtime/boot verification.", "",
              "## Package counts"]
    report += [f"- {key}: {value}" for key, value in data["counts"].items()]
    report += ["", "## Unique Intel additions", ", ".join(data["intel_additions"]) or "(none)",
               "", "## Unique Air additions", ", ".join(data["air_additions"]) or "(none)",
               "", "## Service symlink states"]
    for name, state in service_states.items():
        report.append(f"### {name}")
        report += [f"- {unit}: {entry['state']}" +
                   (f" -> {entry['target']}" if entry.get("target") else "")
                   for unit, entry in state.items()]
    report += ["", "## Interpretation limits"] + [f"- {note}" for note in data["limits"]]
    (args.out / "package-inventory.md").write_text("\n".join(report) + "\n")
    print(json.dumps(data["counts"], sort_keys=True))

if __name__ == "__main__":
    main()
