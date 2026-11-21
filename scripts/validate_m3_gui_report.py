#!/usr/bin/env python3
"""Validate M3 UTM GUI evidence metadata; does not authenticate screenshots.

This is a report shape/consistency gate only. A human must inspect actual
M3-hosted UTM screenshots and VM test logs before accepting graphical proof.
No Mac/UTM/desktop access, file discovery or network I/O is performed.
"""
from __future__ import annotations

import argparse
from datetime import datetime
import json
from pathlib import Path, PurePosixPath
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec/m3-gui-acceptance.json"
SHA = re.compile(r"^[0-9a-f]{40}$")


def evidence_name_ok(value: object) -> bool:
    if not isinstance(value, str) or not value.strip() or "\\" in value or ":" in value:
        return False
    path = PurePosixPath(value)
    return (not path.is_absolute() and len(path.parts) > 1
            and not any(part in (".", "..") for part in value.split("/")))


def utc_time_ok(value: object) -> bool:
    if not isinstance(value, str) or not value.endswith("Z"):
        return False
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).tzinfo is not None
    except ValueError:
        return False


def template(spec: dict) -> dict:
    return {
        "schema_version": 1,
        "pass_id": spec["pass_id"],
        "source_commit": "NOT_PINNED",
        "host_class": "NOT_VERIFIED",
        "guest_architecture": "NOT_VERIFIED",
        "guest_version": "NOT_RUN",
        "vm_profile": "NOT_RUN",
        "native_asahi": "NOT_RUN",
        "overall": "NOT_RUN",
        "results": [
            {
                "id": c["id"],
                "status": "NOT_RUN",
                "observed_at_utc": None,
                "evidence_refs": [],
                "actual": "",
                "expected": c["requirement"],
            } for c in spec["cases"] + spec["optional_cases"]
        ],
    }


def validate(report: dict, spec: dict) -> list[str]:
    errors = []
    if report.get("schema_version") != 1 or report.get("pass_id") != spec["pass_id"]:
        errors.append("Schema version or pass ID mismatch")
    if report.get("native_asahi") != "NOT_RUN":
        errors.append("Native Asahi acceptance is outside this UTM VM report")
    required = {x["id"]: x for x in spec["cases"]}
    optional = {x["id"]: x for x in spec["optional_cases"]}
    allowed = required | optional
    records = report.get("results")
    if not isinstance(records, list):
        return errors + ["Results must be an array"]
    seen = set()
    observed = {}
    for item in records:
        if not isinstance(item, dict) or not isinstance(item.get("id"), str):
            errors.append("Invalid test case record")
            continue
        key = item["id"]
        if key in seen or key not in allowed:
            errors.append(f"Duplicate or unknown case ID: {key}")
            continue
        seen.add(key)
        status = item.get("status")
        if status not in spec["statuses"]:
            errors.append(f"{key}: invalid status")
            continue
        observed[key] = status
        refs = item.get("evidence_refs")
        if not isinstance(refs, list) or any(not evidence_name_ok(ref) for ref in refs):
            errors.append(f"{key}: evidence_refs must be sanitized relative references")
        if status == "PASS":
            if not refs:
                errors.append(f"{key}: PASS needs an evidence reference")
            if not utc_time_ok(item.get("observed_at_utc")):
                errors.append(f"{key}: PASS needs a UTC observation time")
            if not isinstance(item.get("actual"), str) or not item["actual"].strip():
                errors.append(f"{key}: PASS needs an observed result")
            if not isinstance(item.get("expected"), str) or not item["expected"].strip():
                errors.append(f"{key}: PASS needs expected behavior")
    for key in required:
        if key not in seen:
            errors.append(f"Required test case missing: {key}")
    if observed.get("NATIVE-M3-01") not in (None, "NOT_RUN"):
        errors.append("NATIVE-M3-01 must remain NOT_RUN in the UTM pass")
    statuses = [observed.get(key, "NOT_RUN") for key in required]
    if "FAIL" in statuses:
        derived = "FAIL"
    elif "BLOCKED" in statuses:
        derived = "BLOCKED"
    elif statuses and all(status == "PASS" for status in statuses):
        derived = "PASS"
    else:
        derived = "NOT_RUN"
    if report.get("overall") != derived:
        errors.append(f"Overall status must be {derived}")
    if derived == "PASS":
        if not SHA.fullmatch(str(report.get("source_commit", ""))):
            errors.append("PASS needs an immutable 40-hex source commit")
        if report.get("host_class") != "Apple M3 family macOS":
            errors.append("PASS needs observed Apple M3 host class")
        if report.get("guest_architecture") != "aarch64":
            errors.append("PASS needs observed ARM64 guest architecture")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", nargs="?", type=Path, help="Local, sanitized report JSON")
    parser.add_argument("--template", action="store_true", help="Print NOT_RUN template; no file writes")
    args = parser.parse_args()
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    if args.template:
        print(json.dumps(template(spec), indent=2))
        return 0
    if args.report is None:
        parser.error("Supply a report JSON path or --template")
    try:
        report = json.loads(args.report.read_text(encoding="utf-8"))
        if not isinstance(report, dict):
            raise ValueError("Report must be a JSON object")
        errors = validate(report, spec)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"M3 GUI report error: {exc}", file=sys.stderr)
        return 2
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print("M3 GUI metadata contract: PASS (screenshots and host remain unverified)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
