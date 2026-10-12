#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Uninstaller for Goodix 27c6:5125 fingerprint driver on Arch Linux
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "ERROR: Please run as root (e.g. sudo $0)" >&2
    exit 1
fi

TARGET_DIR="/usr/local/lib/goodix-27c6-5125"
DROPIN_DIR="/etc/systemd/system/fprintd.service.d"
DROPIN_FILE="$DROPIN_DIR/90-goodix-5125-runtime.conf"

echo "==> Stopping fprintd.service..."
systemctl stop fprintd.service || true

if [ -f "$DROPIN_FILE" ]; then
    echo "==> Removing systemd drop-in override..."
    rm -f "$DROPIN_FILE"
    rmdir "$DROPIN_DIR" 2>/dev/null || true
fi

if [ -f "/etc/pam.d/plasmalogin" ]; then
    echo "==> Removing /etc/pam.d/plasmalogin..."
    rm -f "/etc/pam.d/plasmalogin"
fi

if [ -d "$TARGET_DIR" ]; then
    echo "==> Removing $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
fi

echo "==> Reloading systemd..."
systemctl daemon-reload

echo "==> Restored stock fprintd configuration."
