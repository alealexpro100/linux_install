#!/bin/bash
###############################################################
### Initial install script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ./version_install ]]; then
  cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
fi
echo "Startring ${BASH_SOURCE[0]} v$(cat ./version_install)"

#Use libraries
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-${BASH_SOURCE[0]%/*}/bin/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ./lib/common/lib_connect.sh
# shellcheck disable=SC1091
source ./lib/common/lib_var_op.sh

if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

# shellcheck disable=SC1091
[[ -f ./public_parametres ]] && source ./public_parametres
# shellcheck disable=SC1091
[[ -f ./private_parametres ]] && source ./private_parametres


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

CONFIG_FILE="$1"

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
  msg_print note "Installed $distr with $CONFIG_FILE to $dir."
else
  return_err "No file $CONFIG_FILE!"
fi

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
