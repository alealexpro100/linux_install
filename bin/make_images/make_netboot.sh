#!/bin/bash
###############################################################
### Make linux_install iso
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

#Use library
if [[ -z $ALEXPRO100_LIB_VERSION ]]; then
  if [[ -z $ALEXPRO100_LIB_LOCATION ]]; then
    ALEXPRO100_LIB_LOCATION="${BASH_SOURCE[0]%/*}/../alexpro100_lib.sh"
    if [[ -f $ALEXPRO100_LIB_LOCATION ]]; then
      echo "Using $ALEXPRO100_LIB_LOCATION."
    else
      echo -e "ALEXPRO100_LIB_LOCATION is not set!"; exit 1
    fi
  fi
  source "$ALEXPRO100_LIB_LOCATION"
fi

function unpack_initfs() (
    cd -- "$2" || return_err "No directory $2!"
    gunzip -d < "$1" | cpio -iv
)

function pack_initfs_zstd() (
    cd -- "$1" || return_err "No directory $1!"
    find . | cpio --quiet -H newc -o | zstd -T12 -10 > "$2"
)

function squashfs_rootfs_pack() (
    cd -- "$1" || return_err "No directory $1!"
    mksquashfs . "$2" -noappend -comp "$3"
)

function make_bootable_iso() (
    cd -- "$1" || return_err "No directory $1!"
    mkisofs -o "$2"  -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -no-emul-boot -boot-load-size 4 -lJR -boot-info-table .; 
)

[[ $UID != 0 ]] && return_err "This script requries root permissions!"

# Check options.
if [[ -z $5 ]]; then
  echo "Make iso linux_install based on alpine iso."
  echo "Example: $0 alpine/v3.13/releases/x86_64/netboot ./linux_install_files x86_64 lts ./netboot_final"
  exit 1
fi

orig_netboot="$1" iso_files="$2" arch="$3" version="$4" netboot_final="$5"

create_tmp_dir make_netboot
mkdir "$make_netboot/final_netboot" "$make_netboot/rootfs"
cp -a "$orig_netboot"/{vmlinuz,initramfs,modloop}-"$version" "$make_netboot/final_netboot"
cp -r "./custom/." "$make_netboot/custom"
cp -r "$iso_files/custom/." "$make_netboot/custom"
mkdir -p "$make_netboot/initfs"
initramfs_name="$(find "$make_netboot/final_netboot" -name "*initramfs-lts" | head -n 1)"
unpack_initfs "$initramfs_name" "$make_netboot/initfs"
rm -rf "$initramfs_name"
mv "$make_netboot/initfs/init" "$make_netboot/initfs/init_orig"
cp "$iso_files/init" "$make_netboot/initfs/init"
pack_initfs_zstd "$make_netboot/initfs" "$make_netboot/final_netboot/initfs.img"
mount -t tmpfs tmpfs "$make_netboot/rootfs"
cp "./auto_configs/alpine_rootfs_$arch.sh" "$make_netboot/config.sh"
echo "add_var \"declare -gx\" \"copy_setup_script\" \"1\"" >> "$make_netboot/config.sh"
CUSTOM_DIR="$make_netboot/custom" default_dir="$make_netboot/rootfs" "./install_sys.sh" "$make_netboot/config.sh" || return_err "Something went wrong!"
squashfs_rootfs_pack "$make_netboot/rootfs" "$make_netboot/final_netboot/rootfs.img" xz
umount "$make_netboot/rootfs"
cp -a "$make_netboot/final_netboot/." "$netboot_final/"
rm -rf "$make_netboot"

# =)
echo "Script succesfully ended its work. Have a nice day!"