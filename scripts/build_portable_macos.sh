#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_VERSION="$(awk '/^AppVersionStr /{print $2}' "${SCRIPT_DIR}/../Telegram/build/version")"

VERSION="${1:-$DEFAULT_VERSION}"
APP_PATH="${2:-out/Release/DeGram.app}"
OUTPUT_DIR="${3:-.}"

echo "==> DeGram Desktop macOS Portable Packager v${VERSION}"

if [ ! -d "$APP_PATH" ]; then
    for cand in "out/Release/DeGram.app" "out/Debug/DeGram.app" "out/DeGram.app"; do
        if [ -d "$cand" ]; then
            APP_PATH="$cand"
            break
        fi
    done
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App bundle not found at $APP_PATH. Build DeGram first (see docs/building-mac.md)."
    exit 1
fi

PACKAGE_NAME="DeGram-Portable-${VERSION}-macOS"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT
PORTABLE_DIR="${TEMP_DIR}/DeGram"

mkdir -p "${PORTABLE_DIR}"
mkdir -p "${PORTABLE_DIR}/DeGramForcePortable"

# Copy macOS Application Bundle
echo "==> Copying application bundle to portable directory..."
cp -R "$APP_PATH" "${PORTABLE_DIR}/DeGram.app"

# Ensure executable permissions on all binaries inside bundle
find "${PORTABLE_DIR}/DeGram.app/Contents/MacOS" -type f -exec chmod 755 {} + || true
if [ -d "${PORTABLE_DIR}/DeGram.app/Contents/Frameworks" ]; then
    find "${PORTABLE_DIR}/DeGram.app/Contents/Frameworks" -type f -perm -111 -exec chmod 755 {} + || true
fi

# Write macOS Portable User Guide
cat << EOF > "${PORTABLE_DIR}/README.txt"
========================================================================
                      DeGram Desktop - macOS Portable Edition
========================================================================

Version: ${VERSION} (macOS)

HOW TO RUN:
-----------
1. Open this folder in Finder.
2. Double-click "DeGram.app".

NOTE ON MACOS GATEKEEPER / QUARANTINE:
--------------------------------------
If macOS reports "DeGram.app is damaged and can't be opened" or blocks
execution due to Gatekeeper quarantine, open Terminal and run:

    xattr -cr "/path/to/DeGram/DeGram.app"

Then open DeGram.app normally.

PORTABLE STORAGE:
-----------------
All user accounts, chats, SQLite anti-recall databases (ayudata.db),
preferences, and cached files are stored strictly inside the
"DeGramForcePortable" folder located right next to DeGram.app.

To move your entire DeGram installation, simply copy the entire "DeGram"
folder to a USB flash drive or another Mac.

DURESS / PANIC WIPE (KABOOM):
-----------------------------
Entering the duress passcode, or 10 wrong local passcodes in a row
(configurable, 0 = off), deletes DeGramForcePortable/tdata and exits.
Files are deleted, not securely overwritten.
========================================================================
EOF

mkdir -p "${OUTPUT_DIR}"
FINAL_ZIP="$(cd "${OUTPUT_DIR}" && pwd)/${PACKAGE_NAME}.zip"

if [ -f "${FINAL_ZIP}" ]; then
    rm -f "${FINAL_ZIP}"
fi

echo "==> Compressing to ${FINAL_ZIP}..."
(cd "${TEMP_DIR}" && zip -r -q -9 "${FINAL_ZIP}" DeGram)

echo "==> Generating SHA256 checksum..."
(cd "$(dirname "${FINAL_ZIP}")" && sha256sum "$(basename "${FINAL_ZIP}")" > "${FINAL_ZIP}.sha256")

echo "==> Successfully created: ${FINAL_ZIP}"
