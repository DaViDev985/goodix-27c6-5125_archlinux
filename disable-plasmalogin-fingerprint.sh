#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Disable fingerprint authentication for Plasma Login Manager on Arch Linux
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "ERROR: Please run as root (e.g. sudo $0)" >&2
    exit 1
fi

PAM_FILE="/etc/pam.d/plasmalogin"

if [ -f "$PAM_FILE" ]; then
    echo "==> Removing $PAM_FILE..."
    rm -f "$PAM_FILE"
    echo "==> Restored default Plasma Login Manager PAM configuration."
else
    echo "==> $PAM_FILE does not exist; default configuration is already active."
fi
