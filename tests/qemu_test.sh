#!/bin/bash
###############################################################
### Test linux_install for directories.
### Copyright (C) 2020 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ../version_install ]]; then
  cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  echo "Location changed!"
fi

#Use library
export ALEXPRO100_LIB_LOCATION="../bin/alexpro100_lib.sh"
source ../lib/common/lib_connect.sh

if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

if [[ -z "$*" ]]; then
  return_err "No options!"
fi

for distr_install in "$@"; do
  [[ ! -d ../lib/distr/$distr_install ]] && return_err "Directory $distr_install not found!"
  msg_print msg "Started on $(date -u)."
  msg_print msg "Testing $distr_install..."
  create_tmp_dir tmp_distr_install
  size=10;
  dd if=/dev/zero of="$tmp_distr_install/disk.img" bs=$((1024*1024)) count=$((size*1024)) status=progress
  disk_id="$(losetup --show -Pf "$tmp_distr_install/disk.img")"
  echo -e "label: dos\n 2048,$((size*2*1024*1024-2048-1)),L" | sfdisk "${disk_id}"
  mkfs.ext4 "${disk_id}"p1
  mkdir -p "$tmp_distr_install/rootfs"
  mount "${disk_id}"p1 "$tmp_distr_install/rootfs"
  bootloader_type_default=bios default_distr=$distr_install default_dir="$tmp_distr_install/rootfs" ECHO_MODE=auto bash ../profile_gen.sh "$tmp_distr_install/used_config"
  sed -ie "s|\"${disk_id}p1\"|\"${disk_id}\"|" "$tmp_distr_install/used_config"
  msg_print warn "Start of profile file."
  cat "$tmp_distr_install/used_config"
  msg_print warn "End of profile file."
  ../install_sys.sh "$tmp_distr_install/used_config" || msg_print error "Something went wrong!"
  umount "$tmp_distr_install/rootfs"
  losetup -D "${disk_id}"
  qemu-system-x86_64 -hda "$tmp_distr_install/disk.img" -m 6G
  rm -rf "$tmp_distr_install"
done

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
