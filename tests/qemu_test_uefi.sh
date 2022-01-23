#!/bin/bash

set -e

if [[ ! -f ./version_install ]]; then
  cd "${BASH_SOURCE[0]%/*}/.."
  [[ ! -f ./version_install ]] && echo "Failed to locate version_install." && exit 1
fi

#Use library
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-./lib/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ./lib/common/lib_connect.sh

[[ $UID != 0 ]] && return_err "This script requries root permissions!"

[[ -z "$*" ]] && return_err "No options!"

for distr_install in "$@"; do
  [[ ! -d ./lib/distr/$distr_install ]] && return_err "Directory $distr_install not found!"
  msg_print msg "Started on $(date -u)."
  msg_print msg "Testing $distr_install..."
  create_tmp_dir tmp_distr_install
  size=4
  dd if=/dev/zero of="${tmp_distr_install:?}/disk.img" bs=$((1024*1024*1024)) count=$((size)) status=progress
  disk_id="$(losetup --show -Pf "$tmp_distr_install/disk.img")"
  echo -e "label: gpt\n ,512M,U\n,,L" | sfdisk "${disk_id}"
  mkfs.vfat -F32 "${disk_id}"p1
  mkfs.ext4 "${disk_id}"p2
  mkdir -p "$tmp_distr_install/rootfs"
  mount "${disk_id}"p2 "$tmp_distr_install/rootfs"
  mkdir "$tmp_distr_install/rootfs/boot"
  mount "${disk_id}"p1 "$tmp_distr_install/rootfs/boot"
  BOOTLOADER_TYPE_DEFAULT=uefi DEFAULT_DISTR=$distr_install DEFAULT_DIR="$tmp_distr_install/rootfs" kernel_type=virtual bootloader_bios_place="${disk_id}" ECHO_MODE=auto bash ./profile_gen.sh "$tmp_distr_install/used_config"
  msg_print warn "Start of profile file."
  cat "$tmp_distr_install/used_config"
  msg_print warn "End of profile file."
  ./install_sys.sh "$tmp_distr_install/used_config" || msg_print error "Something went wrong!"
  umount --lazy "$tmp_distr_install/rootfs"
  losetup -D "${disk_id}"
  qemu-system-x86_64 -bios /usr/share/ovmf/x64/OVMF.fd -hda "$tmp_distr_install/disk.img" -m 3G || msg_print error "Qemu returned error $?."
  rm -rf "$tmp_distr_install"
done
