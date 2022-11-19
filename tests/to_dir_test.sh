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

err_count=$((0)) succ_count=$((0)) iter_count=$((0))
failed_lines=""
test_name="install distro with default profile to directory"

msg_print note "Started test: $test_name."

for distr_install in "$@"; do
  [[ ! -d ./lib/distr/$distr_install ]] && return_err "Directory $distr_install not found!"
  : $((iter_count++))
  msg_print msg "Started on $(date -u)."
  msg_print msg "==\nTesting $distr_install...\n=="
  create_tmp_dir tmp_distr_install
  DEFAULT_DISTR=$distr_install DEFAULT_DIR="${tmp_distr_install:?}/rootfs" ECHO_MODE=auto bash ./profile_gen.sh "$tmp_distr_install/used_config"
  msg_print warn "Start of profile file."
  cat "$tmp_distr_install/used_config"
  msg_print warn "End of profile file."
  mkdir "$tmp_distr_install/rootfs"
  mount -t tmpfs tmpfs "$tmp_distr_install/rootfs"
  if ./install_sys.sh "$tmp_distr_install/used_config"; then
    : $((succ_count++))
  else
    msg_print error "Something went wrong!"
    failed_lines+="\n$distr_install"
    : $((err_count++))
  fi
  umount -l "$tmp_distr_install/rootfs"
  rm -rf "$tmp_distr_install"
  msg_print msg "Ended on $(date -u)."
done

msg_print note "Completed test: $test_name."
msg_print msg "Results: success: $succ_count, error: $err_count, iterations: $iter_count."

if [[ $err_count == 0 ]]; then
  exit 0
else
  msg_print err "Failed lines: $failed_lines"
  exit 1
fi
