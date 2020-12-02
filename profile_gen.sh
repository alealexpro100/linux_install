#!/bin/bash
###############################################################
### Install profile generator script 0.2.1
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

[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres

# Example: *read_param 'Enter smth: ' smth yes_or_no* will add to var config smth=...
# TODO: add support of ncurses and GUI.
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
    var_list[$var]="declare -gx $var=\"$tmp\"" 
    declare -gx $var="$tmp"
  fi
}

msg_print note 'This script for installing linux supposes that directory for installantion is prepared.'

if [[ -z $1 ]]; then
  profile_file="./auto_configs/latest_used.sh"
else
  profile_file="$1"
fi
msg_print msg "Profile will be written into $profile_file"

#Get distribution variable (distr).
declare -A var_list=()
echo "Choose distribution for installation."
echo -e "Avaliable distributions: \n$(ls -1 ./lib/distr)"
while ! [[ -d ./lib/distr/$distr &&  $distr != '' ]]; do
  read_param "Distribution: " "" distr text
done

source ./lib/common/common_options.sh
source ./lib/distr/$distr/distr_options.sh

profile_text="#Latest generated profile."
for var in "${!var_list[@]}"; do
  profile_text="$profile_text\n${var_list[$var]}"
done
echo -e "$profile_text" | sort > $profile_file

msg_print msg "Profile was succesfully generated to $profile_file"

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
