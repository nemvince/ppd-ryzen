#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/usr/lib/systemd/system}"
SYSCONFDIR="${SYSCONFDIR:-/etc}"

if [[ $EUID -ne 0 ]]; then
    echo "This uninstaller must be run as root (use sudo)." >&2
    exit 1
fi

echo "==> Stopping and disabling service"
systemctl disable --now ryzenadj-ppd.service 2>/dev/null || true

echo "==> Removing files"
rm -f "$PREFIX/bin/ryzenadj-ppd"
rm -f "$SYSTEMD_DIR/ryzenadj-ppd.service"

systemctl daemon-reload

cat <<EOF

Done. Your config file has NOT been removed:
  $SYSCONFDIR/ryzenadj-ppd.conf

Delete it manually if you no longer need it.
EOF
