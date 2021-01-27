#!/bin/bash
###############################################################
### Install profile generator script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ ! -f ./version_install ]]; then
  cd "$(dirname $(realpath ${BASH_SOURCE[0]}))"
  echo "Location changed!"
fi

#Use library
ALEXPRO100_LIB_LOCATION="./bin/alexpro100_lib.sh"
source ./lib/common/lib_connect.sh

[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres

# TODO: add support of whiptail (with back option).
function read_param() {
  local dialog="$1" default_var=$2 var=$3 option=$4 tmp=''
  # CLI MODE.
  case $ECHO_MODE in
    auto)
      case $option in
        yes_or_no) tmp=1;;
        no_or_yes) tmp=0;;
        text) tmp=$default_var;;
        text_empty) tmp=$default_var;;
        secret) tmp=$default_var;;
        secret_empty) tmp=$default_var;;
        *) return_err "Option $option is incorrect!";;
      esac
    ;;
    cli|'')     
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
            read -e -s -p "$dialog" -i "$default_var" tmp; echo ""
          done
        ;;
        secret_empty)
          read -e -s -p "$dialog" -i "$default_var" tmp; echo ""
        ;;
        *)
          return_err "Option $option is incorrect!"
        ;;
      esac
    ;;
    *)
      return_err "Incorrect paramater $ECHO_MODE! Mistake?"
    ;;
  esac
  var_list[$var]="declare -gx $var=\"$tmp\"" 
  declare -gx $var="$tmp"
}

msg_print note 'This script for installing linux supposes that directory for installantion is prepared.'

if [[ -z $1 ]]; then
  profile_file="./auto_configs/last_gen.sh"
else
  profile_file="$1"
fi
msg_print msg "Profile will be written into $profile_file"

declare -A var_list=()
echo "Choose distribution for installation."
echo -e "Avaliable distributions: \n$(ls -1 ./lib/distr)"
while ! [[ -d ./lib/distr/$distr &&  $distr != '' ]]; do
  read_param "Distribution: " "$default_distr" distr text
done

source ./lib/common/common_options.sh
source ./lib/distr/$distr/distr_options.sh

profile_text="#Generated on $(date -u)\n#Latest generated profile."
for var in "${!var_list[@]}"; do
  profile_text="$profile_text\n${var_list[$var]}"
done
#Dirty hack.
echo -e "$profile_text" | sort > $profile_file

msg_print msg "Profile was succesfully generated to $profile_file"

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
