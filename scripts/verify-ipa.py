#!/usr/bin/env python3
"""Verify a signed App Store IPA before it is uploaded. Standard library plus native macOS tools only.

Checks Info.plist (bundle id, version, build, minimum OS, device family, platform), the code
signature (team, Apple Distribution authority, strict deep verification, entitlements) and the
embedded provisioning profile (app id, team, store distribution, expiry, signing certificate).
Nothing secret is read or printed: no private keys, no certificate bodies, no entitlement dumps.

Usage: verify-ipa.py APP.ipa --bundle-id ID --version X.Y.Z --build N --team TEAM [--min-os 17.0]
"""
import argparse
import datetime
import hashlib
import os
import plistlib
import re
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

FAMILIES = [1, 2]
errors = []


def check(condition, message):
    if not condition:
        errors.append(message)
    return condition


def version_tuple(text):
    return tuple(int(part) for part in text.split("."))


def run(command, binary=False):
    result = subprocess.run(command, capture_output=True)
    if binary:
        return result
    return result.returncode, result.stdout.decode(errors="replace"), result.stderr.decode(errors="replace")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("ipa")
    parser.add_argument("--bundle-id", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--build", required=True)
    parser.add_argument("--team", required=True)
    parser.add_argument("--min-os", default="17.0", help="lowest acceptable MinimumOSVersion (the app floor)")
    parser.add_argument("--require-resource", action="append", default=[], metavar="NAME",
                        help="file that must exist at the top level of the .app (presence only, never read)")
    args = parser.parse_args()

    ipa = Path(args.ipa)
    if not ipa.is_file():
        sys.exit(f"IPA not found: {ipa}")
    if not re.fullmatch(r"[0-9]+", args.build):
        sys.exit("--build must be an integer")

    with zipfile.ZipFile(ipa) as archive:
        plists = [n for n in archive.namelist() if re.fullmatch(r"Payload/[^/]+\.app/Info\.plist", n)]
        if len(plists) != 1:
            sys.exit(f"expected exactly one Payload/*.app/Info.plist, found {len(plists)}")
        info = plistlib.loads(archive.read(plists[0]))
        app_prefix = plists[0].rsplit("/", 1)[0]
        for name in args.require_resource:
            check(f"{app_prefix}/{name}" in archive.namelist(), f"{name} is missing from the app bundle")

    check(info.get("CFBundleIdentifier") == args.bundle_id, "CFBundleIdentifier does not match the expected bundle id")
    check(info.get("CFBundleShortVersionString") == args.version,
          f"CFBundleShortVersionString is {info.get('CFBundleShortVersionString')!r}, expected {args.version!r}")
    check(info.get("CFBundleVersion") == args.build,
          f"CFBundleVersion is {info.get('CFBundleVersion')!r}, expected {args.build!r}")
    minimum = str(info.get("MinimumOSVersion", ""))
    if check(re.fullmatch(r"[0-9]+(\.[0-9]+)*", minimum) is not None, "MinimumOSVersion is missing or malformed"):
        check(version_tuple(minimum) >= version_tuple(args.min_os),
              f"MinimumOSVersion {minimum} is below the app floor {args.min_os}")
    check(sorted(info.get("UIDeviceFamily", [])) == FAMILIES,
          f"UIDeviceFamily is {info.get('UIDeviceFamily')!r}, expected {FAMILIES}")
    check(info.get("CFBundleSupportedPlatforms") == ["iPhoneOS"], "CFBundleSupportedPlatforms is not ['iPhoneOS']")
    check(info.get("DTPlatformName") == "iphoneos", "DTPlatformName is not iphoneos")

    with tempfile.TemporaryDirectory(prefix="verify-ipa-") as scratch:
        scratch = Path(scratch)
        code, _, err = run(["ditto", "-x", "-k", str(ipa), str(scratch / "x")])
        if code != 0:
            sys.exit("could not extract the IPA with ditto")
        apps = list((scratch / "x" / "Payload").glob("*.app"))
        if len(apps) != 1:
            sys.exit("expected exactly one .app in Payload")
        app = apps[0]

        code, _, err = run(["codesign", "--verify", "--deep", "--strict", str(app)])
        check(code == 0, "codesign --verify --deep --strict failed")

        code, _, details = run(["codesign", "-dvv", str(app)])
        check(code == 0, "codesign -dvv failed")
        team = re.search(r"^TeamIdentifier=(\S+)$", details, re.M)
        check(team is not None and team.group(1) == args.team, "code signature TeamIdentifier does not match the team")
        authorities = re.findall(r"^Authority=(.+)$", details, re.M)
        check(any(a.startswith("Apple Distribution:") and f"({args.team})" in a for a in authorities),
              "signing identity is not an Apple Distribution certificate of the team")

        result = run(["codesign", "-d", "--entitlements", ":-", str(app)], binary=True)
        entitlements = {}
        if check(result.returncode == 0 and result.stdout.strip() != b"", "could not read the signed entitlements"):
            entitlements = plistlib.loads(result.stdout)
        app_id = f"{args.team}.{args.bundle_id}"
        check(entitlements.get("application-identifier") == app_id, "signed application-identifier is not TEAM.bundle-id")
        check(entitlements.get("com.apple.developer.team-identifier") == args.team,
              "signed team-identifier entitlement does not match the team")
        check(entitlements.get("get-task-allow") in (None, False), "get-task-allow is enabled; this is not a store build")

        profile_path = app / "embedded.mobileprovision"
        profile = {}
        if check(profile_path.is_file(), "embedded.mobileprovision is missing"):
            code, out, _ = run(["security", "cms", "-D", "-i", str(profile_path)])
            if check(code == 0, "security cms could not decode the provisioning profile"):
                profile = plistlib.loads(out.encode())
        profile_entitlements = profile.get("Entitlements", {})
        check(profile_entitlements.get("application-identifier") == app_id,
              "profile application-identifier is not TEAM.bundle-id")
        check(args.team in profile.get("TeamIdentifier", []), "profile TeamIdentifier does not include the team")
        check("ProvisionedDevices" not in profile and not profile.get("ProvisionsAllDevices"),
              "profile is a development or ad hoc profile, not App Store distribution")
        expires = profile.get("ExpirationDate")
        if check(isinstance(expires, datetime.datetime), "profile has no ExpirationDate"):
            check(expires > datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None),
                  "provisioning profile has expired")

        prefix = scratch / "cert"
        run(["codesign", "-d", f"--extract-certificates={prefix}", str(app)])
        leaf = Path(f"{prefix}0")
        if check(leaf.is_file(), "could not extract the signing certificate"):
            fingerprint = hashlib.sha256(leaf.read_bytes()).hexdigest()
            allowed = {hashlib.sha256(bytes(c)).hexdigest() for c in profile.get("DeveloperCertificates", [])}
            check(fingerprint in allowed, "signing certificate is not listed in the provisioning profile")

    if errors:
        annotate = os.environ.get("GITHUB_ACTIONS") == "true"
        for message in errors:
            print(f"::error title=IPA verification::{message}" if annotate else f"error: {message}", file=sys.stderr)
        sys.exit(f"IPA verification failed ({len(errors)} problem(s)); nothing was uploaded.")
    print(f"IPA verified: {args.bundle_id} {args.version} ({args.build}), min iOS {minimum}, team {args.team}")


main()
