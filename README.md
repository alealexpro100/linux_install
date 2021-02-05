linux_install
=============

## About
This script installs a base linux system from any linux distribution.
Tested on Alpinelinux (musl) and Archlinux (glibc).
Supported for installing Linux distros:
* Alpine
* Archlinux
* Debian-based distros
* Voidlinux

## Requirements
* Connection to mirror with packages for installing distrubution.
* Prepared directory for installing system (if uefi, with mounted /boot partition).
* Installed tools: `coreutils bash wget tar zstd` OR `busybox bash zstd`.
* (Optional) For deboostrap: `perl binutils` OR `perl dpkg`.
* (Optional) For foreign architectures and qemu test: qemu-user-static (QEMU_STATIC_BIN_DIR flag supported).

## Usage
* Prepare directory for installation.
* Execute `./profile_gen.sh` and answer questions OR find one of prepared in `./auto_configs`.
* Execute `./install_sys.sh your/profile.sh` using installation profile to install system.
* That's all. You have installed system. Good luck!

## Contents of project:
* auto-configs/ - Directory with working configs for auto installation.
* bin/ - Tools for this script. They use only `alexpro100_lib.sh`.
* custom/ - Your custom script and files. See `custom/README_custom.md`.
* lib/ - Installation files. Easy-to-edit installation system.
* orphaned/ - Parts not used in script, but kept for future usage.
* tests/ - Testing scripts. See `tests/README_tests.md`.
* install_sys.sh - Main script. Requries profile for work.
* profile_gen.sh - Profile generator.
* private_parametres - File with private parametres. Your parametres.
* public_parametres - File with public parametres. Do NOT delete it.
* version_install - Version of this script.

## Sources:

* http://ftp.debian.org/debian/pool/main/d/debootstrap/ -- deboostrap.
* https://www.archlinux.org/packages/extra/any/arch-install-scripts/download/ -- Parts from arch-chroot and genfstab.