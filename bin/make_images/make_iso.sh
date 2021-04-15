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

function make_bootable_iso() (
    cd -- "$1" || return_err "No directory $1!"
    mkisofs -o "$2"  -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -no-emul-boot -boot-load-size 4 -lJR -boot-info-table .; 
)

[[ $UID != 0 ]] && return_err "This script requries root permissions!"

# Check options.
if [[ -z $4 ]]; then
  echo "Make iso linux_install based on alpine iso."
  echo "Example: $0 alpine/v3.13/releases/x86_64/alpine-extended-3.13.4-x86_64.iso ./linux_install_files x86_64 final.iso"
  exit 1
fi

orig_iso="$1" iso_files="$2" arch="$3" iso_file="$4"

create_tmp_dir make_iso
mkdir "$make_iso/orig_iso" "$make_iso/final_iso" "$make_iso/initfs" "$make_iso/rootfs" "$make_iso/custom"
cp -r "./custom/." "$make_iso/custom"
cp -r "$iso_files/custom/." "$make_iso/custom"
mount "$orig_iso" "$make_iso/orig_iso"
cp -a "$make_iso/orig_iso/." "$make_iso/final_iso"
umount "$make_iso/orig_iso"
initramfs_name="$(find "$make_iso/final_iso/boot" -name "*initramfs-*" | head -n 1)"
unpack_initfs_gz "$initramfs_name" "$make_iso/initfs"
mv "$make_iso/initfs/init" "$make_iso/initfs/init_orig"
cp "$iso_files/init" "$make_iso/initfs/init"
pack_initfs_cpio "$make_iso/initfs" | zstd -T12 -10 > "$initramfs_name"
mount -t tmpfs tmpfs "$make_iso/rootfs"
cp "./auto_configs/linux_install_$arch.sh" "$make_iso/config.sh"
CUSTOM_DIR="$make_iso/custom" default_dir="$make_iso/rootfs" "./install_sys.sh" "$make_iso/config.sh"
squashfs_rootfs_pack "$make_iso/rootfs" "$make_iso/final_iso/apks/rootfs.img" xz
umount "$make_iso/rootfs"
sed -ie 's/quiet/quiet rootfs_net=rootfs.img/' "$make_iso/final_iso/boot/syslinux/syslinux.cfg"
make_bootable_iso "$make_iso/final_iso" "$iso_file"
rm -rf "$make_iso"

# =)
echo "Script succesfully ended its work. Have a nice day!"