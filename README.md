linux_install
=============

## About
This script installs a base linux system from any linux distribution.
Tested on Alpinelinux (musl) and Archlinux (glibc).
Supported Linux distros for installation:
* Alpine
* Archlinux
* Debian-based distros
* Voidlinux

## Requirements
* Connection to mirror with packages for installing distrubution.
* Prepared directory for installing system (if uefi, with mounted /boot partition).
* Installed tools: `coreutils util-linix bash wget tar zstd` OR `busybox bash zstd findmnt lsblk`.
* (Optional) For deboostrap: `perl binutils` OR `perl dpkg`.
* (Optional) For foreign architectures: qemu-user-static (QEMU_STATIC_BIN_DIR flag supported).

## Usage
* Prepare directory for installation.
* Execute `./profile_gen.sh` and answer questions OR find one of prepared in `./auto_configs`.
* Execute `./install_sys.sh your/profile.sh` using installation profile to install system.
* That's all. You have installed system. Good luck!

## Supported flags:
* `LIVE_MODE` - Will be used for live install. (No full support yet.)
* `CUSTOM_DIR` - Path to custom script and files.
* `ECHO_MODE` - Mode of interface (cli/whiptail).
* `INSTALL_LANG` - Language for install interface. (NOT of target system!)
* `ALEXPRO100_LIB_DEBUG` - Debug mode for alexpro100 lib.

## Contents of project:
* auto-configs/ - Directory with working configs for auto installation.
* bin/ - Tools for this script. They use only `alexpro100_lib.sh`.
* bin/mirror_sync - Tools for making local mirror of packages.
* custom/ - Your custom script and files. See `custom/README_custom.md`.
* lib/ - Installation files. Easy-to-edit installation system.
* orphaned/ - Old parts of script. Are kept for future usage.
* tests/ - Testing scripts. See `tests/README_tests.md`.
* install_sys.sh - Main script. Requries profile for work.
* profile_gen.sh - Profile generator.
* private_parametres - File with private parametres. Your parametres.
* public_parametres - File with public parametres. Do NOT delete it.
* version_install - Version of this script.

## Sources:

* http://ftp.debian.org/debian/pool/main/d/debootstrap/ -- deboostrap.
* https://www.archlinux.org/packages/extra/any/arch-install-scripts/download/ -- Parts from arch-chroot and genfstab.