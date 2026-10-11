#!/usr/bin/env bash
# Build a distributable tarball.
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(cat "$SRC_DIR/version")"
NAME="ryzenadj-ppd"
STAGE="$SRC_DIR/dist/${NAME}-${version}"

echo "==> Building $NAME $version"
rm -rf "$SRC_DIR/dist"
mkdir -p "$STAGE"

cp -r "$SRC_DIR/bin" \
    "$SRC_DIR/etc" \
    "$SRC_DIR/systemd" \
    "$SRC_DIR/scripts" \
    "$SRC_DIR/version" \
    "$SRC_DIR/license" \
    "$SRC_DIR/readme.md" \
    "$STAGE/"

# Strip the dev-only scripts from the distributed tarball
rm -f "$STAGE/scripts/build-package.sh"

cd "$SRC_DIR/dist"
tar --owner=0 --group=0 -czf "${NAME}-${version}.tar.gz" "${NAME}-${version}"
sha256sum "${NAME}-${version}.tar.gz" >"${NAME}-${version}.tar.gz.sha256"

echo "==> Output:"
ls -lh "$SRC_DIR/dist"
