#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/.git/hooks"

if [ ! -d "${HOOKS_DIR}" ]; then
    echo "Error: .git/hooks directory not found at ${HOOKS_DIR}"
    exit 1
fi

cat << 'EOF' > "${HOOKS_DIR}/pre-commit"
#!/usr/bin/env bash
set -e

# Rule: Always bump version on every new commit
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Check if version is already staged for this commit
if ! git diff --cached --name-only | grep -q "^Telegram/build/version$"; then
    echo "==> [Rule Enforcement] Automatically bumping version for new commit..."
    python3 "${REPO_ROOT}/scripts/bump_version.py" patch
    git add "${REPO_ROOT}/Telegram/build/version" "${REPO_ROOT}/Telegram/SourceFiles/core/version.h"
fi
EOF

chmod +x "${HOOKS_DIR}/pre-commit"
echo "==> Successfully installed git pre-commit hook in ${HOOKS_DIR}/pre-commit"
