#!/usr/bin/env bash
# Basic offline sanity checks. Does not require root or ryzenadj.
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BRIDGE="$SRC_DIR/bin/ryzenadj-ppd"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}
pass() { echo "ok - $*"; }

# 1. Bash syntax
bash -n "$BRIDGE" && pass "bash -n"
bash -n "$SRC_DIR/scripts/install.sh" && pass "bash -n install.sh"
bash -n "$SRC_DIR/scripts/uninstall.sh" && pass "bash -n uninstall.sh"

# 2. --version / --help
"$BRIDGE" --version | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' &&
    pass "--version format"
"$BRIDGE" --help | grep -q 'Usage:' &&
    pass "--help output"

# 3. Config file is valid bash
bash -n "$SRC_DIR/etc/ryzenadj-ppd.conf" && pass "config syntax"

# 4. Unknown arg exits non-zero
if "$BRIDGE" --definitely-not-a-flag 2>/dev/null; then
    fail "unknown flag should exit non-zero"
else
    pass "unknown flag rejected"
fi

# 5. systemd unit verifies
if command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze verify "$SRC_DIR/systemd/ryzenadj-ppd.service" &&
        pass "systemd-analyze verify"
else
    echo "skip - systemd-analyze not installed"
fi

echo
echo "All smoke tests passed."
