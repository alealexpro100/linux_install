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

for profile in "$@"; do
  [[ ! -f $profile ]] && return_err "Profile $profile not found!"
  msg_print msg "Started on $(date -u)."
  msg_print msg "Testing $distr_install..."
  create_tmp_dir tmp_distr_install
  cp "$profile" "$tmp_distr_install/used_config"
  msg_print warn "Start of profile file."
  cat "$tmp_distr_install/used_config"
  msg_print warn "End of profile file."
  mkdir "$tmp_distr_install/rootfs"
  mount -t tmpfs tmpfs "$tmp_distr_install/rootfs"
  default_dir="$tmp_distr_install/rootfs" ./install_sys.sh "$tmp_distr_install/used_config" || msg_print error "Something went wrong!"
  umount --lazy "$tmp_distr_install/rootfs"
  rm -rf "$tmp_distr_install"
  msg_print msg "Ended on $(date -u)."
done