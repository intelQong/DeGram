#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_VERSION="$(awk '/^AppVersionStr /{print $2}' "${REPO_ROOT}/Telegram/build/version")"

VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$(uname -m)}"
BINARY_PATH="${3:-out/Release/DeGram}"
OUTPUT_DIR="${4:-.}"

# Normalize architecture naming
case "$ARCH" in
    x86_64|amd64)   ARCH_NAME="x86_64" ;;
    aarch64|arm64)  ARCH_NAME="arm64" ;;
    *)              ARCH_NAME="$ARCH" ;;
esac

if [ ! -f "$BINARY_PATH" ]; then
    for cand in "out/Release/DeGram" "out/Debug/DeGram" "out/DeGram"; do
        if [ -f "$cand" ]; then
            BINARY_PATH="$cand"
            break
        fi
    done
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Usage: ./scripts/build_portable.sh [VERSION] [ARCH] [BINARY_PATH] [OUTPUT_DIR]"
    exit 1
fi

PACKAGE_NAME="DeGram-Portable-${VERSION}-${ARCH_NAME}"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT
PORTABLE_DIR="${TEMP_DIR}/DeGram"

echo "==> Creating portable package: ${PACKAGE_NAME}..."

mkdir -p "${PORTABLE_DIR}"
mkdir -p "${PORTABLE_DIR}/DeGramForcePortable"

# Copy application binary
cp "$BINARY_PATH" "${PORTABLE_DIR}/degram"
chmod 755 "${PORTABLE_DIR}/degram"
ln -sf "degram" "${PORTABLE_DIR}/DeGram"

# Copy desktop and icon assets if available
if [ -f "${REPO_ROOT}/lib/xdg/com.degram.desktop.desktop" ]; then
    cp "${REPO_ROOT}/lib/xdg/com.degram.desktop.desktop" "${PORTABLE_DIR}/"
    chmod 644 "${PORTABLE_DIR}/com.degram.desktop.desktop"
fi

if [ -f "${REPO_ROOT}/Telegram/Resources/art/ayu/default/app.svg" ]; then
    cp "${REPO_ROOT}/Telegram/Resources/art/ayu/default/app.svg" "${PORTABLE_DIR}/degram.svg"
    chmod 644 "${PORTABLE_DIR}/degram.svg"
fi

# Create launcher script
cat << 'EOF' > "${PORTABLE_DIR}/DeGram.sh"
#!/usr/bin/env bash
set -e
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${HERE}/DeGramForcePortable"
exec "${HERE}/degram" -workdir "${HERE}/DeGramForcePortable" "$@"
EOF
chmod 755 "${PORTABLE_DIR}/DeGram.sh"

# Create README with usage instructions
cat << EOF > "${PORTABLE_DIR}/README.txt"
========================================================================
                      DeGram Desktop - Portable Edition
========================================================================

Version: ${VERSION} (${ARCH_NAME})

HOW TO RUN:
-----------
Run either of the following commands from the terminal or file manager:
    ./DeGram.sh
or
    ./degram
or
    ./DeGram

PORTABLE STORAGE:
-----------------
All user profiles, chats, anti-recall database (SQLite), settings, and
cached data are stored strictly inside the "DeGramForcePortable" folder.

To move your entire DeGram installation, simply copy the "DeGram"
folder to a USB flash drive or another computer.

DURESS / PANIC WIPE (KABOOM):
-----------------------------
Entering the duress passcode, or 10 wrong local passcodes in a row
(configurable, 0 = off), deletes DeGramForcePortable/tdata and exits.
Files are deleted, not securely overwritten.
========================================================================
EOF

mkdir -p "${OUTPUT_DIR}"
FINAL_ARCHIVE="$(cd "${OUTPUT_DIR}" && pwd)/${PACKAGE_NAME}.tar.xz"

echo "==> Compressing to ${FINAL_ARCHIVE}..."
tar -cf - -C "${TEMP_DIR}" DeGram | xz -T0 -3 > "${FINAL_ARCHIVE}"

echo "==> Generating SHA256 checksum..."
(cd "$(dirname "${FINAL_ARCHIVE}")" && sha256sum "$(basename "${FINAL_ARCHIVE}")" > "${FINAL_ARCHIVE}.sha256")

echo "==> Successfully created: ${FINAL_ARCHIVE}"
