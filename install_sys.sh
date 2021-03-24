#!/bin/bash
###############################################################
### Initial install script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ./version_install ]]; then
  cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  echo "Location changed!"
fi

#Use libraries
ALEXPRO100_LIB_LOCATION="./bin/alexpro100_lib.sh"
source ./lib/common/lib_connect.sh
source ./lib/common/lib_var_op.sh

if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres


declare -gx cp_safe="cp -Rf"
function custom_actions() {
  [[ -d "$CUSTOM_DIR" ]] || CUSTOM_DIR=./custom
  if [[ -d $CUSTOM_DIR/rootfs ]]; then
    msg_print note "Copying custom files..."
    $cp_safe "$CUSTOM_DIR/rootfs/." "$dir"
  fi
  if [[ -f $CUSTOM_DIR/custom_script.sh && -n "$arch_chroot_command" ]]; then
    cp "$CUSTOM_DIR/custom_script.sh" "$dir/root/custom_script.sh"
    chmod +x "$dir/root/custom_script.sh"
    msg_print note "Executing custom script..."
    $arch_chroot_command "$dir" bash /root/custom_script.sh
    rm -rf "$dir/root/custom_script.sh"
  fi
}

CONFIG_FILE="$1"

if [[ -z $CONFIG_FILE ]]; then
  echo "Main install script. Requries profile for installation."
  echo "Example: $0 profile_install.sh"
  exit 1
fi

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE" || return_err "Failed to use profile!"
  parse_arch $(uname -m)
  source ./lib/distr/$distr/distr_actions.sh
  custom_actions
  msg_print note "Installed $distr with $CONFIG_FILE to $dir."
else
  return_err "No file $CONFIG_FILE!"
fi

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
