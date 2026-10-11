#!/usr/bin/env bash
# Simple installer for ryzenadj-ppd (non-package-manager installs).
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/usr/lib/systemd/system}"
SYSCONFDIR="${SYSCONFDIR:-/etc}"

if [[ $EUID -ne 0 ]]; then
    echo "This installer must be run as root (use sudo)." >&2
    exit 1
fi

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing ryzenadj-ppd"
install -Dm0755 "$SRC_DIR/bin/ryzenadj-ppd" \
    "$PREFIX/bin/ryzenadj-ppd"
install -Dm0644 "$SRC_DIR/systemd/ryzenadj-ppd.service" \
    "$SYSTEMD_DIR/ryzenadj-ppd.service"

if [[ ! -e "$SYSCONFDIR/ryzenadj-ppd.conf" ]]; then
    echo "==> Installing default config to $SYSCONFDIR/ryzenadj-ppd.conf"
    install -Dm0644 "$SRC_DIR/etc/ryzenadj-ppd.conf" \
        "$SYSCONFDIR/ryzenadj-ppd.conf"
else
    echo "==> Existing config found; installing new version as .conf.new"
    install -Dm0644 "$SRC_DIR/etc/ryzenadj-ppd.conf" \
        "$SYSCONFDIR/ryzenadj-ppd.conf.new"
fi

echo "==> Reloading systemd"
systemctl daemon-reload

cat <<EOF

Done.

Next steps:
  1. Ensure 'ryzenadj' is installed (e.g. 'pacman -S ryzenadj' or AUR).
  2. Review limits in: $SYSCONFDIR/ryzenadj-ppd.conf
  3. Enable the service:
       systemctl enable --now ryzenadj-ppd.service
  4. Check logs:
       journalctl -u ryzenadj-ppd.service -f
EOF
