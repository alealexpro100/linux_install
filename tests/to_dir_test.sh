#!/bin/bash
###############################################################
### Test linux_install for directories.
### Copyright (C) 2020 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ../version_install ]]; then
  cd "$(dirname $(realpath ${BASH_SOURCE[0]}))"
  echo "Location changed!"
fi

#Use library
ALEXPRO100_LIB_LOCATION="../bin/alexpro100_lib.sh"
source ../lib/common/lib_connect.sh

if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

for distr_install in $(ls -1 ../lib/distr); do
  msg_print msg "Started on $(date -u)."
  msg_print msg "Testing $distr_install..."
  create_tmp_dir tmp_distr_install
  default_distr=$distr_install default_dir="$tmp_distr_install/rootfs" ECHO_MODE=auto bash ../profile_gen.sh $tmp_distr_install/used_config
  msg_print warn "Start of profile file."
  cat $tmp_distr_install/used_config
  msg_print warn "End of profile file."
  mkdir "$tmp_distr_install/rootfs"
  mount -t tmpfs tmpfs "$tmp_distr_install/rootfs"
  ../install_sys.sh $tmp_distr_install/used_config || msg_print error "Something went wrong!"
  umount "$tmp_distr_install/rootfs"
  rm -rf $tmp_distr_install
done

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
