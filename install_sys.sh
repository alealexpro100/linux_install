#!/usr/bin/env bash
###############################################################
### Initial install script
### Copyright (C) 2021 ALEXPRO100 (alealexpro100)
### License: GPL v3.0
###############################################################

set -e

CONFIG_FILE="$(realpath "$1")"
if [[ ! -f ./version_install ]]; then
  cd "${BASH_SOURCE[0]%/*}"
  [[ ! -f ./version_install ]] && echo "Failed to locate version_install." && exit 1
fi
echo "Starting ${BASH_SOURCE[0]} $(cat ./version_install)"

#Use libraries
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-./lib/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ./lib/common/lib_connect.sh
# shellcheck disable=SC1091
source ./lib/common/lib_var_op.sh

if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

# shellcheck disable=SC1091
[[ -f ./public_parameters ]] && source ./public_parameters
# shellcheck disable=SC1091
[[ -f ./private_parameters ]] && source ./private_parameters


declare -gx cp_safe="cp -Rf"
function custom_actions() {
  [[ -d "$CUSTOM_DIR" ]] || CUSTOM_DIR=./custom
  if [[ -d $CUSTOM_DIR/rootfs ]]; then
    msg_print note "Copying custom files..."
    $cp_safe "$CUSTOM_DIR/rootfs/." "${dir:?}"
  fi
  if [[ -f $CUSTOM_DIR/custom_script.sh && -n "$arch_chroot_command" ]]; then
    cp "$CUSTOM_DIR/custom_script.sh" "$dir/root/custom_script.sh"
    chmod +x "$dir/root/custom_script.sh"
    msg_print note "Executing custom script..."
    $arch_chroot_command "${dir:?}" bash /root/custom_script.sh
    rm -rf "$dir/root/custom_script.sh"
  fi
}

if [[ -z $CONFIG_FILE ]]; then
  echo "Main install script. Requries profile for installation."
  echo "Example: $0 profile_install.sh"
  exit 1
fi

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE" || return_err "Failed to use profile!"
  parse_arch "$(uname -m)"
  # shellcheck disable=SC1090
  source "./lib/distr/${distr:?}/distr_actions.sh"
  custom_actions
  if is_function profile_end_action; then
    profile_end_action || return_err "Couldn't do profile_end_action."
  fi
  msg_print note "Installed $distr with $CONFIG_FILE to $dir."
else
  return_err "No file $CONFIG_FILE!"
fi

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
