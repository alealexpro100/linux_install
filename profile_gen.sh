#!/bin/bash
###############################################################
### Install profile generator script
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

[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres



case $ECHO_MODE in
  whiptail) 
    function print_param() {
      local print_type=$1 text="$2" ww="10" wh="60"
      whiptail --msgbox "$text$dialog" $ww $wh
    }
  ;;
  auto|cli|*) 
    function print_param() {
      local print_type=$1 text="$2"
      msg_print "$print_type" "$text"
    }
  ;;
esac

case $ECHO_MODE in
  auto)
    function read_param() {
      local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
      case $option in
        print) echo -ne "$text$dialog";;
        yes_or_no) tmp=1;;
        no_or_yes) tmp=0;;
        text) tmp=$default_var;;
        text_empty) tmp=$default_var;;
        secret) tmp=$default_var;;
        secret_empty) tmp=$default_var;;
        *) return_err "Option $option is incorrect!";;
      esac
      add_var "declare -gx" "$var" "$tmp"
    }
  ;;
  whiptail)
    function read_param() {
      local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
      ww="15" wh="50"
      case $option in
        yes_or_no)
          tmp=$(whiptail --menu "$text$dialog" $ww $wh 2 "1" "$M_YES" "0" "$M_NO" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        no_or_yes)
          tmp=$(whiptail --menu "$text$dialog" $ww $wh 2 "0" "$M_NO" "1" "$M_YES" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        text)
          while [[ $tmp == '' ]]; do
            tmp=$(whiptail --inputbox "$text$dialog:" $ww $wh "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        text_empty)
          tmp=$(whiptail --inputbox "$text$dialog" $ww $wh "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        secret)
          while [[ $tmp == '' ]]; do
            tmp=$(whiptail --passwordbox "$text$dialog" $ww $wh "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        secret_empty)
          tmp=$(whiptail --passwordbox "$text$dialog" $ww $wh "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        *)
          return_err "Option $option is incorrect!"
        ;;
      esac
      add_var "declare -gx" "$var" "$tmp"
    }
  ;;
  cli|'')
    function read_param() {
      local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
      case $option in
        yes_or_no)
          echo -ne "$text"
          read -r -p "$dialog (Y/n): " -e -i "$default_var" tmp
          if [[ $tmp == 'Y' || $tmp == 'y' || $tmp == 'Yes' || $tmp == 'yes' || $tmp == '' ]]; then
            tmp=1
          else
            tmp=0
          fi
        ;;
        no_or_yes)
          echo -ne "$text"
          read -r -p "$dialog (N\y): " -e -i "$default_var" tmp
          if [[ $tmp == 'N' || $tmp == 'n' || $tmp == 'No' || $tmp == 'no' || $tmp == '' ]]; then
            tmp=0
          else
            tmp=1
          fi
        ;;
        text)
          while [[ $tmp == '' ]]; do
            echo -ne "$text"
            read -r -p "$dialog: " -e -i "$default_var" tmp
          done
        ;;
        text_empty)
          echo -ne "$text"
          read -r -p "$dialog: " -e -p "$dialog: " -i "$default_var" tmp
        ;;
        secret)
          while [[ $tmp == '' ]]; do
            echo -ne "$text"
            read -r -p "$dialog: " -e -s -i "$default_var" tmp; echo ""
          done
        ;;
        secret_empty)
          echo -ne "$text"
          read -r -p "$dialog: " -e -s -i "$default_var" tmp; echo ""
        ;;
        *)
          return_err "Option $option is incorrect!"
        ;;
      esac
      add_var "declare -gx" "$var" "$tmp"
    }
  ;;
  *)
    return_err "Incorrect paramater ECHO_MODE $ECHO_MODE! Mistake?"
  ;;
esac

#Language support.
source ./lib/translations/messages_en.sh
[[ -n $INSTALL_LANG ]] && source "./lib/translations/messages_$INSTALL_LANG.sh"

print_param note "$M_WELCOME"

if [[ $LIVE_MODE != "1" ]]; then
  print_param note "$M_DIR_WARN"
  profile_file="${1:-"./auto_configs/last_gen.sh"}"
  print_param note "$M_PROFILE_1 $profile_file"
  default_dir="${default_dir:-"/mnt/mnt"}"
  read_param "" "$M_PATH $distr" "$default_dir" dir text
fi

while ! [[ -d ./lib/distr/$distr &&  $distr != '' ]]; do
  read_param "$M_DISTR_1: \n$(ls -1 ./lib/distr)\n" "$M_DISTR_2" "$default_distr" distr text
done

print_param note "$M_COMMON_OPT"
source ./lib/common/common_options.sh
print_param note "$M_DISTR_OPT"
source "./lib/distr/$distr/distr_options.sh"

add_var "declare -gx" LANG "$LANG"
var_export > "$profile_file"

[[ $LIVE_MODE != "1" ]] && print_param note "Profile was succesfully written to $profile_file"

# =)
echo "$M_NICE"
exit 0
