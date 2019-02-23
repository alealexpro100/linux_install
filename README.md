linux_install
=============

## Requirements
* Stable internet (recomendation) OR stable connection to YOUR local mirror with packages for installing distrubution. (only for first step)
* Prepared directory for installing system (for uefi, with mounted YOUR_DIR/boot partition).
* Installed tools: bash, coreutils (or busybox), perl (for debian installaion), qemu (for emulation).

## Usage

### Manual method.
* Prepare directory for installation.
* Execute `./install_sys.sh` and answer questions.
* Boot to installed system (if you installed it as a core system), login to root, execute `./pi_s2.sh` and answer qustions.
* That's all. You have installed system. Good luck!

### Automatic method.
* Prepare directory for installation.
* Execute `./install_sys.sh path_to_config`.
* Boot to installed system (if you installed it as a core system), login to root, execute `./pi_s2.sh` and answer qustions.
* That's all. You have installed system. Good luck!

## About

!!!ALL CODE NEEDS CLEANING!!!

It installs a base linux system from any GNU distro.
No warranty.
You can use bootstrap scripts for your own purposes. They work with arch-chroot script.

Now it supports:
* Debian (and debian-based distros).
* Archlinux.
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
