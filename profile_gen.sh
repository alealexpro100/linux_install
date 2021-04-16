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
source ./lib/common/lib_ui.sh

[[ -f ./public_parametres ]] && source ./public_parametres
[[ -f ./private_parametres ]] && source ./private_parametres

#Language support.
msg_dir="${msg_dir:-./lib/msg/}"
msg_file_list="$(find "$msg_dir" | sed "s|$msg_dir||g;s|.sh||g;/^$/d")"
[[ -f "$msg_dir/$LANG_INSTALLER.sh" ]] || LANG_INSTALLER=en
source "$msg_dir/$LANG_INSTALLER.sh"
read_param "$M_MSG_M: \n$msg_file_list\n" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER text_check "$(echo "$msg_file_list" | tr '\n' ',')"
source "$msg_dir/$LANG_INSTALLER.sh"

print_param note "$M_WELCOME"

if [[ $LIVE_MODE == "1" ]]; then
  profile_file="/tmp/last_gen.sh"
  add_var "declare -gx" "dir" "${DEFAULT_DIR:-"/mnt/mnt"}"
else
  profile_file="${1:-"./auto_configs/last_gen.sh"}"
  print_param note "$M_DIR_WARN\n$M_PROFILE_1 $profile_file"
  read_param "" "$M_PATH $distr" "${DEFAULT_DIR:-"/mnt/mnt"}" dir text
fi

profile_dir="${profile_dir:-./lib/distr/}"
distr_list="$(find "$profile_dir" -maxdepth 1 -type d | sed "s|$profile_dir||g;/^$/d")"
read_param "$M_DISTR_1: \n$distr_list\n" "$M_DISTR_2" "$DEFAULT_DISTR" distr text_check "$(echo "$distr_list" | tr '\n' ',')"

AP100_DBG print_param note "$M_COMMON_OPT"
source ./lib/common/common_options.sh
AP100_DBG print_param note "$M_DISTR_OPT"
source "./lib/distr/$distr/distr_options.sh"
#Final menu for changes.
var_final=''
until [[ $var_final == "0" ]]; do
  #Make menu, We use array to make parametres.
  vars_list=("0" "$M_LIST_FINAL_END_OPTION")
  for ((i=1; i<${#var_num[@]}; i++)); do
    var=${var_num[i]}
    [[ $var == "var_final" ]] && continue
    vars_list=("${vars_list[@]}" "$i")
    if [[ ${!var} == "0" || ${!var} == "1" ]]; then
      if [[ ${!var} == "1" ]]; then
        vars_list=("${vars_list[@]}" "${M_VAR_DESCRIPTION[$var]:-$var} | $M_YES")
      else
        vars_list=("${vars_list[@]}" "${M_VAR_DESCRIPTION[$var]:-$var} | $M_NO")
      fi
    else
      vars_list=("${vars_list[@]}" "${M_VAR_DESCRIPTION[$var]:-$var} | ${!var}")
    fi 
  done
  #Print menu.
  read_param "$M_LIST_FINAL_TEXT" "$M_LIST_FINAL_DIALOG" "0" var_final menu "${vars_list[@]}"
  #Decide what we have to do: change param and show menu again or end selection.
  if [[ $var_final != 0 ]]; then
    var="${var_num[$((${var_final#0}))]}"
    if [[ ${!var} == "0" || ${!var} == "1" ]]; then
      if [[ ${!var} == "0" ]]; then
        read_param "" "${M_VAR_DESCRIPTION[$var]:-$var}" "" "$var" no_or_yes
      else
        read_param "" "${M_VAR_DESCRIPTION[$var]:-$var}" "" "$var" yes_or_no
      fi
    else
      read_param "" "${M_VAR_DESCRIPTION[$var]:-$var}" "${!var}" "$var" text
    fi
  fi
done

add_var "declare -gx" LANG "$LANG"
{
  echo -e "#Generated on $(date -u).\n"
  var_export "add_var "
} > "$profile_file"

[[ $LIVE_MODE != "1" ]] && print_param note "$M_PROFILE_2 $profile_file"

# =)
echo "$M_NICE"
exit 0
