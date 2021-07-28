#!/bin/bash
###############################################################
### Make linux_install iso
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-${BASH_SOURCE[0]%/*}/../../lib/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source "${BASH_SOURCE[0]%/*}/../../lib/common/lib_connect.sh"

[[ $UID != 0 ]] && return_err "This script requries root permissions!"

# Check options.
if [[ -z $5 ]]; then
  echo "Make linux_install netboot files based on alpine netboot files."
  echo "Example: $0 alpine/v3.13/releases/x86_64/netboot ./linux_install_files x86_64 lts ./netboot_final"
  exit 1
fi

orig_netboot="$1" iso_files="$2" arch="$3" version="$4" netboot_final="$(realpath "$5")"

create_tmp_dir make_netboot
mkdir "$make_netboot/final_netboot" "$make_netboot/rootfs"
cp -a "$orig_netboot"/{vmlinuz,initramfs,modloop}-"$version" "$make_netboot/final_netboot"
cp -r "./custom/." "$make_netboot/custom"
cp -r "$iso_files/custom/." "$make_netboot/custom"
mkdir -p "$make_netboot/initfs"
initramfs_name="$(find "$make_netboot/final_netboot" -name "*initramfs-lts" | head -n 1)"
unpack_initfs_gz "$initramfs_name" "$make_netboot/initfs"
rm -rf "$initramfs_name"
mv "$make_netboot/initfs/init" "$make_netboot/initfs/init_orig"
cp "$iso_files/init" "$make_netboot/initfs/init"
pack_initfs_cpio "$make_netboot/initfs" | zstd -T12 -10 > "$make_netboot/final_netboot/initfs.img"
mount -t tmpfs tmpfs "$make_netboot/rootfs"
cp "./auto_configs/linux_install_$arch.sh" "$make_netboot/config.sh"
CUSTOM_DIR="$make_netboot/custom" default_dir="$make_netboot/rootfs" "./install_sys.sh" "$make_netboot/config.sh"
squashfs_rootfs_pack "$make_netboot/rootfs" "$make_netboot/final_netboot/rootfs.img" xz
umount "$make_netboot/rootfs"
cp -a "$make_netboot/final_netboot/." "$netboot_final/"
rm -rf "$make_netboot"

# =)
echo "Script succesfully ended its work. Have a nice day!"