#!/usr/bin/env bash
# Create or delete a dedicated, CI-owned iOS simulator.
# Usage: SIMULATOR_PREFIX=App-CI scripts/simulator.sh create   -> prints the simulator UDID
#        SIMULATOR_PREFIX=App-CI scripts/simulator.sh delete <udid>
# Optional: SIMULATOR_MIN_IOS (default 17.0) is the lowest acceptable iOS runtime.
# Only simulators whose name starts with "$SIMULATOR_PREFIX-" are ever deleted.
set -euo pipefail

prefix="${SIMULATOR_PREFIX:?SIMULATOR_PREFIX is required}"
min_ios="${SIMULATOR_MIN_IOS:-17.0}"

case "${1:-}" in
  create)
    selection=$(xcrun simctl list runtimes available -j | python3 -c '
import json, sys

def version(text):
    return tuple(int(part) for part in text.split("."))

minimum = version(sys.argv[1])
runtimes = [
    r for r in json.load(sys.stdin)["runtimes"]
    if r.get("isAvailable", True)
    and r.get("platform", "iOS") == "iOS"
    and version(r["version"]) >= minimum
]
if not runtimes:
    sys.exit("No available iOS simulator runtime >= " + sys.argv[1])
runtime = max(runtimes, key=lambda r: version(r["version"]))
phones = [t for t in runtime.get("supportedDeviceTypes", []) if t.get("productFamily") == "iPhone"]
if not phones:
    sys.exit("No iPhone device type for " + runtime["identifier"])
preferred = [t for t in phones if t["name"] == "iPhone 17 Pro"]
device = (preferred or phones)[-1]
print(runtime["identifier"])
print(device["identifier"])
' "$min_ios")
    runtime=$(printf '%s\n' "$selection" | sed -n 1p)
    device_type=$(printf '%s\n' "$selection" | sed -n 2p)
    name="${prefix}-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-0}-$$"
    xcrun simctl create "$name" "$device_type" "$runtime"
    ;;
  delete)
    udid="${2:-}"
    [ -n "$udid" ] || { echo "usage: $0 delete <udid>" >&2; exit 1; }
    name=$(xcrun simctl list devices -j | python3 -c '
import json, sys

for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["udid"] == sys.argv[1]:
            print(device["name"])
' "$udid")
    if [ -z "$name" ]; then
      echo "Simulator $udid no longer exists"
      exit 0
    fi
    case "$name" in
      "${prefix}-"*) ;;
      *) echo "Refusing to delete simulator '$name': not created by this CI" >&2; exit 1 ;;
    esac
    xcrun simctl shutdown "$udid" 2>/dev/null || true
    xcrun simctl delete "$udid"
    ;;
  *)
    echo "usage: $0 create | delete <udid>" >&2
    exit 1
    ;;
esac
