#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Enable fingerprint authentication for Plasma Login Manager on Arch Linux
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "ERROR: Please run as root (e.g. sudo $0)" >&2
    exit 1
fi

PAM_FILE="/etc/pam.d/plasmalogin"

echo "==> Configuring $PAM_FILE..."
cat > "$PAM_FILE" << 'EOF'
#%PAM-1.0
# Fingerprint & Password login for Plasma Login Manager
# Typing your password logs in directly and unlocks KWallet.
# Submitting an empty password activates fingerprint authentication.

auth        [success=1 new_authtok_reqd=1 default=ignore] pam_unix.so try_first_pass likeauth nullok
auth        sufficient  pam_fprintd.so max-tries=3 timeout=30
auth        include     /usr/lib/pam.d/plasmalogin
account     include     /usr/lib/pam.d/plasmalogin
password    include     /usr/lib/pam.d/plasmalogin
session     include     /usr/lib/pam.d/plasmalogin
EOF

chmod 644 "$PAM_FILE"
echo "==> Successfully enabled fingerprint authentication for Plasma Login Manager!"
echo ""
echo "How it works:"
echo "  - Type your password + Enter: logs in normally (and unlocks your KWallet)."
echo "  - Press Enter on an empty password: waits for your fingerprint to log in."
