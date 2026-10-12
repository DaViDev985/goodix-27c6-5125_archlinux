#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Installer for Goodix 27c6:5125 fingerprint driver on Arch Linux
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "ERROR: Please run as root (e.g. sudo $0)" >&2
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BUILD_DIR="$SCRIPT_DIR/build"
BUILD_LIB=""

for candidate in \
    "$SCRIPT_DIR/build/libfprint/libfprint-2.so.2.0.0" \
    "$SCRIPT_DIR/test_build/libfprint/libfprint-2.so.2.0.0" \
    "$SCRIPT_DIR/goodix-27c6-5125/test_build/libfprint/libfprint-2.so.2.0.0"; do
    if [ -f "$candidate" ]; then
        BUILD_LIB="$candidate"
        break
    fi
done

if [ -z "$BUILD_LIB" ]; then
    echo "==> Built library not found. Compiling libfprint driver with meson..."
    meson setup "$BUILD_DIR" "$SCRIPT_DIR/reference/libfprint-fedora44-1.94.100/source" \
        --prefix=/usr --libdir=lib --buildtype=release --wrap-mode=nodownload \
        -Ddrivers=goodix_27c6_5125 -Dintrospection=false -Ddoc=false -Dinstalled-tests=false \
        -Dudev_rules=disabled -Dudev_hwdb=disabled -Dgoodix_production_minimal=true \
        -Dc_args='["-DGOODIX_PRODUCTION_FPRINTD_ACTION_PROFILE"]' \
        -Dcpp_args='["-DGOODIX_PRODUCTION_FPRINTD_ACTION_PROFILE"]'
    meson compile -C "$BUILD_DIR" fprint-2
    BUILD_LIB="$BUILD_DIR/libfprint/libfprint-2.so.2.0.0"
fi

TARGET_DIR="/usr/local/lib/goodix-27c6-5125"
STATE_DIR="/var/lib/fprint/goodix-5125-state-v2"
DROPIN_DIR="/etc/systemd/system/fprintd.service.d"
DROPIN_FILE="$DROPIN_DIR/90-goodix-5125-runtime.conf"

echo "==> Installing Goodix 27c6:5125 libfprint driver to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cp -f "$BUILD_LIB" "$TARGET_DIR/libfprint-2.so.2.0.0"
ln -sf libfprint-2.so.2.0.0 "$TARGET_DIR/libfprint-2.so.2"
ln -sf libfprint-2.so.2 "$TARGET_DIR/libfprint-2.so"
chmod 755 "$TARGET_DIR"
chmod 755 "$TARGET_DIR/libfprint-2.so.2.0.0"

echo "==> Preparing secure pairing state directory $STATE_DIR..."
mkdir -p "$STATE_DIR"
chown root:root "$STATE_DIR"
chmod 700 "$STATE_DIR"

echo "==> Installing systemd drop-in override for fprintd.service..."
mkdir -p "$DROPIN_DIR"
cat > "$DROPIN_FILE" << 'EOF'
[Service]
Environment=LD_LIBRARY_PATH=/usr/local/lib/goodix-27c6-5125
EOF
chmod 644 "$DROPIN_FILE"

echo "==> Reloading systemd and restarting fprintd.service..."
systemctl daemon-reload
systemctl restart fprintd.service || true

echo ""
echo "==> Installation complete! Checking fprintd device recognition..."
sleep 1
if fprintd-list "$SUDO_USER" >/dev/null 2>&1; then
    echo "SUCCESS: fprintd recognized your fingerprint reader!"
    fprintd-list "$SUDO_USER" || true
else
    echo "Note: fprintd started. You can now test enrollment with:"
    echo "  fprintd-enroll"
fi
