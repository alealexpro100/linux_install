linux_install
=============

## About
This script installs a base linux system from any linux distribution.
Connection to mirror with packages for installing distribution is requried.
Tested on Alpinelinux (musl) and Archlinux (glibc).
Supported Linux distros for installation:
* Alpine
* Archlinux
* Debian
* Voidlinux

## Dependencies
### Requried
* `coreutils util-linux bash wget tar zstd` - For normal system
* `busybox bash zstd findmnt lsblk` - For busybox system
### Optional
* `perl dpkg` - debootstrap
* `rpm2cpio` - rpm-bootstrap
* `qemu-user-static` - foreign architectures
### Build
* `squashfs-tools cdrtools` - live installer build

## Usage
### Live installer
#### Manual mode
##### From ISO
* Download latest `linux_install-*.iso` file from releases.
* Boot from it. UEFI and BIOS systems are supported.
* Follow install instructions.
* That's all. You have installed system. Good luck!
##### From PXE (IPXE)
* Download latest `linux_install-*.pxe.tar.gz` file from releases.
* Unpack it to boot server. Variable `${linux_url}` is a url to directory with needed files.
* To boot it from IPXE there is two necessary kernel options: `modloop=${linux_url}/modloop-lts rootfs_net=${linux_url}/rootfs.img`.
* Follow install instructions.
* That's all. You have installed system. Good luck!
#### Auto mode
* You will need ready to use profile. (see example `./auto_configs/example_auto_profile.sh`)
* You will need add kernel option `AUTO_PROFILE=URL_TO_YOUR_PROFILE`. 
* (ISO) You can add this while booting from ISO in bootloader by pressing 'e' and when adding the option.
* (PXE) Just add the option before loading kernel and initramfs.
* That's all. You have installed system. Good luck!
### Standalone
* Prepare directory for installation.
* Clone this repo.
* Execute `./profile_gen.sh` and answer questions OR use one of prepared in `./auto_configs`.
* Execute `./install_sys.sh your/profile.sh` using installation profile to install system.
* That's all. You have installed system. Good luck!

## Building
* Clone this repo: `git clone https://github.com/alealexpro100/linux_install`.
* Change location of ALPINE_FILES in `./bin/make_images/build.sh`. Some variables can be changed without changing file.
* Run it from **root**: `sudo ./bin/make_images/build.sh`.
* Images will be located at directory `./linux_install_builds`.

## Supported variables
* `AUTO_PROFILE` - Kernel option for live installer. URL of profile for auto mode.
* `REBOOT_AFTER` - Used for auto mode. If set to `0`, prevents system from rebooting after installation. 
* `CUSTOM_DIR` - Path to custom script and files.
* `ECHO_MODE` - Mode of interface (auto/cli/dialog).
* `LANG_INSTALLER` - Language for install interface. (NOT of target system!)
* `QEMU_STATIC_BIN_DIR` - Directory with qemu-static binaries.
* `ALEXPRO100_LIB_DEBUG` - Debug mode for alexpro100_lib.sh.
* `LIVE_MODE` - Used for live installation.
* `DEFAULT_DIR` - Default directory for installation.
* `DEFAULT_DISTR` - Default distribution for installation.
* `BOOTLOADER_TYPE_DEFAULT` - Default type of bootloader for installation.

## Contents of project
* auto-configs/ - Directory with working configs for auto installation.
* bin/ - Tools used by script.
* bin/make_images - Build live installer.
* custom/ - Custom script and files. See `custom/README_custom.md`.
* lib/ - Installation files. Easy-to-edit installation system.
* tests/ - Testing scripts. See `tests/README_tests.md`.
* install_sys.sh - Install script. Requires profile for work.
* profile_gen.sh - Profile generator.
* private_parameters - File with private parameters.
* public_parameters - File with public parameters. Do NOT remove it.
* version_install - Version of this script.

## Sources
* http://ftp.debian.org/debian/pool/main/d/debootstrap/ -- deboostrap.
* https://www.archlinux.org/packages/extra/any/arch-install-scripts/download/ -- Parts from arch-chroot and genfstab.
* https://alpinelinux.org/downloads/ -- Distribution used in builds.
