#!/usr/bin/env bash
set -e

VERSION="${1:-7.0.16}"
ARCH="${2:-amd64}"
BINARY_PATH="${3:-out/Release/DeGram}"
OUTPUT_DIR="${4:-.}"

# Normalize architecture naming
case "$ARCH" in
    x86_64|amd64)   ARCH_NAME="x86_64" ;;
    aarch64|arm64)  ARCH_NAME="arm64" ;;
    *)              ARCH_NAME="$ARCH" ;;
esac

if [ ! -f "$BINARY_PATH" ]; then
    for cand in "$BINARY_PATH" "DeGram-Portable-${ARCH_NAME}/degram" "out/Release/DeGram" "out/Debug/DeGram" "out/Release/Telegram" "out/Debug/Telegram" "out/bin/DeGram" "out/bin/Telegram" "out/DeGram" "out/Telegram" "../out/Release/DeGram" "../out/Release/Telegram"; do
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
TEMP_DIR="/tmp/${PACKAGE_NAME}_$$"
PORTABLE_DIR="${TEMP_DIR}/DeGram"

echo "==> Creating portable package: ${PACKAGE_NAME}..."

rm -rf "${TEMP_DIR}"
mkdir -p "${PORTABLE_DIR}"
mkdir -p "${PORTABLE_DIR}/DeGramForcePortable"
mkdir -p "${PORTABLE_DIR}/TelegramForcePortable"
touch "${PORTABLE_DIR}/portable"

# Copy application binary
cp "$BINARY_PATH" "${PORTABLE_DIR}/degram"
chmod 755 "${PORTABLE_DIR}/degram"
ln -sf "degram" "${PORTABLE_DIR}/DeGram"

# Copy desktop and icon assets if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
No data is written to ~/.local/share or ~/.config.

To move your entire DeGram installation, simply copy the "DeGram"
folder to a USB flash drive or another computer.

DURESS / PANIC WIPE (KABOOM):
-----------------------------
If the duress passcode or fail-safe bad attempts wipe is triggered,
all data inside the portable folder (tdata, databases, cache) is
completely and recursively wiped, and the process immediately terminates.
========================================================================
EOF

mkdir -p "${OUTPUT_DIR}"
FINAL_ARCHIVE="$(cd "${OUTPUT_DIR}" && pwd)/${PACKAGE_NAME}.tar.xz"

echo "==> Compressing to ${FINAL_ARCHIVE}..."
tar -cf - -C "${TEMP_DIR}" DeGram | xz -T0 -3 > "${FINAL_ARCHIVE}"

echo "==> Generating SHA256 checksum..."
(cd "$(dirname "${FINAL_ARCHIVE}")" && sha256sum "$(basename "${FINAL_ARCHIVE}")" > "${FINAL_ARCHIVE}.sha256")

echo "==> Successfully created: ${FINAL_ARCHIVE}"
rm -rf "${TEMP_DIR}"
exit 0
