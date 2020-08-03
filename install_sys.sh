#!/bin/bash
###############################################################
### Initial install script 0.2.1
### Copyright (C) 2020 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ -f ./version_install ]]; then
  echo "Running linux_install $(cat ./version_install)."
else
  echo "Incorrect location!"; exit 1
fi

#Use library
if [[ -z $ALEXPRO100_LIB_VERSION ]]; then
  if [[ -z $ALEXPRO100_LIB_LOCATION ]]; then
    if [[ -f ./bin/alexpro100_lib.sh ]]; then
      ALEXPRO100_LIB_LOCATION=./bin/alexpro100_lib.sh
      echo "Using $ALEXPRO100_LIB_LOCATION."
    else
      echo -e "ALEXPRO100_LIB_LOCATION is not set!"; return 1
    fi
  fi
  source $ALEXPRO100_LIB_LOCATION
fi

# Only root can run this script.
if [[ $UID != 0 ]]; then
  return_err "This script requries root permissions!"
fi

#Loading parametres...
[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres

function custom_actions() {
  if [[ -d ./custom/rootfs ]]; then
    msg_print note "Copying custom files..."
    cp -arf ./custom/rootfs/* $dir/
  fi
  if [[ -f ./custom/custom_script.sh && ! -z $arch_chroot_command ]]; then
    cp {./custom,$dir/root}/custom_script.sh
    chmod +x $dir/root/custom_script.sh
    msg_print note "Executing custom script..."
    $arch_chroot_command $dir bash /root/custom_script.sh
    rm -rf $dir/root/custom_script.sh
  fi
}

#...Auto mode.
if [[ -f $1 ]]; then
  var_list=()
  function add_var {
    var_list=("${var_list[@]}" "$1")
    export $1="$2"
  }
  source $1 || exit 1
  parse_arch $(uname -m)
  source ./lib/distr/$distr/distr_actions.sh
  custom_actions
  msg_print note "Installed $distr with $1 to $dir."
  exit 0
fi

# Example: *read_param 'Enter smth: ' smth yes_or_no* will add to var config smth=...
# Plan: add support of ncurses and GUI.
function read_param() {
  local dialog="$1" default_var=$2 var=$3 option=$4 tmp=''
  # CLI MODE.
  if [[ $echo_mode = '' || $echo_mode = 'cli' ]]; then
    case $option in
      yes_or_no)
        read -e -p "$dialog" -i "$default_var" tmp
        if [[ $tmp == 'Y' || $tmp == 'y' || $tmp == 'Yes' || $tmp == 'yes' || $tmp == '' ]]; then
          tmp=1
        else
          tmp=0
        fi
      ;;
      no_or_yes)
        read -e -p "$dialog" -i "$default_var" tmp
        if [[ $tmp == 'N' || $tmp == 'n' || $tmp == 'No' || $tmp == 'no' || $tmp == '' ]]; then
          tmp=0
        else
          tmp=1
        fi
      ;;
      text)
        while [[ $tmp == '' ]]; do
          read -e -p "$dialog" -i "$default_var" tmp
        done
      ;;
      text_empty)
        read -e -p "$dialog" -i "$default_var" tmp
      ;;
      secret)
        while [[ $tmp == '' ]]; do
          read -e -s -p "$dialog" -i "$default_var" tmp
        done
      ;;
      secret_empty)
        read -e -s -p "$dialog" -i "$default_var" tmp
      ;;
      *)
      return_err "Option $option is incorrect!"
      ;;
    esac
    var_list=("${var_list[@]}" "$var")
    export $var="$tmp"
  fi
}

msg_print note 'This script for installing linux supposes that directory for installantion is prepared.'

#Get distribution variable (distr).
var_list=()
echo "Choose distribution for installation."
echo -e "Avaliable distributions: \n$(ls -1 ./lib/distr)"
while ! [[ -d ./lib/distr/$distr &&  $distr != '' ]]; do
  read_param "Distribution: " "" distr text
done

source ./lib/common/common_options.sh
source ./lib/distr/$distr/distr_options.sh
read_param "You're about to start installing $distr to $dir. Do you really want to continue? (Y/n): " "" enter yes_or_no
if [[ $enter == 0 ]]; then
  return_err "Aborted by user!"
fi

rm -rf ./auto_configs/latest_used.sh
for var in ${var_list[@]}; do
  echo -e "add_var $var \"${!var}\"" >> ./auto_configs/latest_used.sh
done
source ./lib/distr/$distr/distr_actions.sh
custom_actions


msg_print note "Distribution $distr was installed to $dir."

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
