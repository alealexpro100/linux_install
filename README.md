linux_install
=============

## Requirements
* Stable connection to mirror with packages for installing distrubution.
* Prepared directory for installing system (for uefi, with mounted /boot partition).
* Installed tools: coreutils, bash, wget.
* Optinal: perl (for debian installaion), qemu (for foreign arches).

## Usage
* Prepare directory for installation.
* Execute `./install_sys.sh` and answer questions OR Execute `./install_sys.sh path_to_config`. (You can find them in ./auto_configs)
* That's all. You have installed system. Now you can boot it. Good luck!

## About

Install a base linux system from any GNU distro.
ABSOLUTELY NO WARRANTY.

Supported linux distros:
* Debian (and debian-based distros).
* Archlinux.
* Void linux.
* Alpine (only bootstrap script).

### Contents:
* auto-configs/ - Directory with working example configs for auto installation.
* bin/ - Directory with binaries for this script.
* disr/ - Directory with distro-specific installation files.
* install_sys.sh - Main script.
* private_parametres - File with private_parametres. It's like public_parametres.
* public_parametres - Files with public_parametres.
* version_install - Version of this script.

## Thanks to...

* http://ftp.debian.org/debian/pool/main/d/debootstrap/ -- Bootstraping of debian.
* https://www.archlinux.org/packages/extra/any/arch-install-scripts/download/ -- arch-chroot and genfstab scripts.
* https://github.com/tokland/arch-bootstrap/blob/master/arch-bootstrap.sh -- Some parts of code for arch-bootstrap.
