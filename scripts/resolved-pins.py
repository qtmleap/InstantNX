#!/usr/bin/env python3
"""Print "yes" when Package.resolved pins QuantumLeap to a released tag (>= 1.0.0), else "no".

CI passes -onlyUsePackageVersionsFromResolvedFile only once the committed lock carries the
real tag, so a stale lock never turns the build red for the wrong reason.
"""
import json
import sys
from pathlib import Path


def main():
    path = Path(sys.argv[1])
    if not path.is_file():
        print("no")
        return
    pins = json.loads(path.read_text()).get("pins", [])
    for pin in pins:
        if pin.get("identity", "").lower() != "quantumleap":
            continue
        version = pin.get("state", {}).get("version", "")
        major = version.split(".")[0]
        print("yes" if major.isdigit() and int(major) >= 1 and pin["state"].get("revision") else "no")
        return
    print("no")


main()
