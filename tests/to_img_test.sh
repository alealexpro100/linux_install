#!/bin/bash
###############################################################
### Test linux_install for directories.
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ../version_install ]]; then
  cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  echo "Location changed!"
fi

#Use library
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-../bin/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ../lib/common/lib_connect.sh

[[ $UID != 0 ]] && return_err "This script requries root permissions!"

[[ -z "$*" ]] && return_err "No options!"

for distr_install in "$@"; do
  [[ ! -d ../lib/distr/$distr_install ]] && return_err "Directory $distr_install not found!"
  msg_print msg "Started on $(date -u)."
  msg_print msg "Testing $distr_install..."
  create_tmp_dir tmp_distr_install
  dd if=/dev/zero of="${tmp_distr_install:?}/disk.img" bs=1M count=4096 status=progress
  mkfs.ext4 "$tmp_distr_install/disk.img"
  mkdir -p "$tmp_distr_install/rootfs"
  mount "$tmp_distr_install/disk.img" "$tmp_distr_install/rootfs" 
  DEFAULT_DISTR=$distr_install DEFAULT_DIR="$tmp_distr_install/rootfs" ECHO_MODE=auto bash ../profile_gen.sh "$tmp_distr_install/used_config"
  msg_print warn "Start of profile file."
  cat "$tmp_distr_install/used_config"
  msg_print warn "End of profile file."
  ../install_sys.sh "$tmp_distr_install/used_config" || msg_print error "Something went wrong!"
  umount "$tmp_distr_install/rootfs"
  rm -rf "$tmp_distr_install"
done

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
