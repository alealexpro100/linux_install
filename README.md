linux_install
=============

## About
This script installs a base linux system from any linux distribution.
Supported linux distros:
* Alpine
* Archlinux
* Debian-based distros
* Voidlinux

## Requirements
* Connection to mirror with packages for installing distrubution.
* Prepared directory for installing system (if uefi, with mounted /boot partition).
* Installed tools: coreutils, bash, wget (or curl), tar, zstd.
* Optinal: perl (for debootstrap), qemu-user-static (for foreign architectures).

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
* install_sys.sh - Main script. Requries profile for work.
* profile_gen.sh - Profile generator.
* private_parametres - File with private parametres. Your parametres.
* public_parametres - File with public parametres. Do NOT delete it.
* version_install - Version of this script.

## Sources:

* http://ftp.debian.org/debian/pool/main/d/debootstrap/ -- deboostrap.
* https://www.archlinux.org/packages/extra/any/arch-install-scripts/download/ -- Parts from arch-chroot and genfstab.