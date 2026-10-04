#!/usr/bin/env python3
import sys
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
BUILD_VERSION_FILE = REPO_ROOT / "Telegram" / "build" / "version"
VERSION_H_FILE = REPO_ROOT / "Telegram" / "SourceFiles" / "core" / "version.h"

def read_current_version():
    content = BUILD_VERSION_FILE.read_text(encoding="utf-8")
    m = re.search(r"^AppVersionStr\s+(\d+)\.(\d+)\.(\d+)", content, re.MULTILINE)
    if not m:
        raise ValueError(f"Could not find AppVersionStr in {BUILD_VERSION_FILE}")
    major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
    return major, minor, patch

def bump_version(part="patch"):
    major, minor, patch = read_current_version()
    if part == "major":
        major += 1
        minor = 0
        patch = 0
    elif part == "minor":
        minor += 1
        patch = 0
    else:
        patch += 1

    app_version_int = major * 1000000 + minor * 1000 + patch
    version_str = f"{major}.{minor}.{patch}"
    version_str_major = f"{major}.{minor}"

    # 1. Update Telegram/build/version
    build_version_content = f"""AppVersion         {app_version_int}
AppVersionStrMajor {version_str_major}
AppVersionStrSmall {version_str}
AppVersionStr      {version_str}
BetaChannel        0
AlphaVersion       0
AppVersionOriginal {version_str}
"""
    BUILD_VERSION_FILE.write_text(build_version_content, encoding="utf-8")

    # 2. Update Telegram/SourceFiles/core/version.h
    vh_content = VERSION_H_FILE.read_text(encoding="utf-8")
    vh_content = re.sub(
        r"constexpr auto AppVersion = \d+;",
        f"constexpr auto AppVersion = {app_version_int};",
        vh_content
    )
    vh_content = re.sub(
        r'constexpr auto AppVersionStr = "[^"]+";',
        f'constexpr auto AppVersionStr = "{version_str}";',
        vh_content
    )
    VERSION_H_FILE.write_text(vh_content, encoding="utf-8")

    print(f"Bumped version to {version_str} (AppVersion: {app_version_int})")
    return version_str, app_version_int

if __name__ == "__main__":
    part = sys.argv[1] if len(sys.argv) > 1 else "patch"
    bump_version(part)
