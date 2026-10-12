<!-- SPDX-License-Identifier: GPL-2.0-or-later -->
# Goodix 27c6:5125 for Arch Linux KDE

Fingerprint driver for the Goodix USB reader `27c6:5125` running
`GF_ST411SEC_APP_12509` or `GF_ST411SEC_APP_12508`. It connects a Goodix-enabled libfprint library to the
system's fprintd service and desktop authentication, initializing the reader by itself on
first use while preserving factory firmware and factory data.

## Supported configuration

- Arch Linux, x86_64, with local user accounts.
- Goodix USB `27c6:5125`, firmware `GF_ST411SEC_APP_12509` and `GF_ST411SEC_APP_12508` (Huawei MateBook / Honor MagicBook).
- Arch-provided fprintd, PAM, Plasma Login (`plasmalogin`), KScreenLocker, sudo and PolicyKit.

Within the supported Arch Linux KDE scope, the project integrates enrollment,
verification, screen unlocking, ordinary sudo, PolicyKit, Plasma fingerprint
login and password fallback through Linux's existing authentication stack.
Qualification is limited to the documented target and one reader; see
[validation and limitations](docs/VALIDATION.md).

## Installation

> [!WARNING]
> **Use only official releases or the `main` branch for installation.**

### 1. Install prerequisites

```bash
sudo pacman -S fprintd libfprint opencv meson ninja gcc pkgconf pam
```

### 2. Build and install

```bash
sudo ./install-arch.sh
```

The installer builds the runtime from source (using `meson` and `ninja`), places the Goodix-enabled library in `/usr/local/lib/goodix-27c6-5125/`, sets up the root-only pairing state directory `/var/lib/fprint/goodix-5125-state-v2/`, and installs a systemd drop-in override for `fprintd.service`.

### 3. (Optional) Enable Plasma Login Manager fingerprint auth

```bash
sudo ./enable-plasmalogin-fingerprint.sh
```

## Using fingerprint authentication

The first fingerprint action initializes the reader by itself.

Manage enrolled fingers through KDE's fingerprint settings. At Plasma Login,
a nonempty password uses ordinary password login immediately. Submitting an
empty password field explicitly selects fingerprint authentication, with at
most three attempts and a stop on the first match. After selecting fingerprint,
allow roughly one second before touching the reader.

Keep password access available. Fingerprint login does not automatically unlock
a password-encrypted KWallet.

## Uninstall and emergency recovery

Run **`sudo ./uninstall-arch.sh`** from a terminal to remove the private library and systemd drop-in override, cleanly restoring the stock `fprintd` configuration while preserving host pairing state and enrolled templates.

To disable the optional Plasma Login Manager PAM integration at any time:
```bash
sudo ./disable-plasmalogin-fingerprint.sh
```

## Learn how it works

New to Linux fingerprint authentication? **[Goodix Behind the Scenes](docs/learning/README.md)**
is a beginner-friendly tour from the desktop prompt to the sensor, image,
template and final match decision. It uses diagrams and plain-language analogies;
the technical manual remains the canonical specification.

## Documentation

- [Beginner learning guide](docs/learning/README.md)
- [Installation and updates](docs/INSTALLATION.md)
- [Uninstall and emergency recovery](docs/UNINSTALL.md)
- [Technical architecture](TECHNICAL_MANUAL.md)
- [Security and privacy](docs/SECURITY.md)
- [Validation scope and known limitations](docs/VALIDATION.md)
- [Licensing and provenance](docs/LICENSING_AND_PROVENANCE.md)
- [Upstream references](docs/REFERENCES.md)
- [Source build and validation checks](production/README.md)

## License and acknowledgements

Licensing is per file. The Goodix-enabled combined library is conveyed under
`GPL-3.0-or-later`; individual files retain their original notices and terms.
See [licensing and provenance](docs/LICENSING_AND_PROVENANCE.md) and
[acknowledgements](ACKNOWLEDGEMENTS.md).
