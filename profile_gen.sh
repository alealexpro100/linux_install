#!/bin/bash
###############################################################
### Install profile generator script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

if [[ -n "$1" ]]; then
  CONFIG_FILE="$(realpath "$1")"
else
  CONFIG_FILE="$(realpath .)/last_gen.sh"
fi
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
# shellcheck disable=SC1091
source ./lib/common/lib_ui.sh

# shellcheck disable=SC1091
if [[ -f ./public_parameters ]]; then
  source ./public_parameters
else
  return_err "Public parameters not found!"
fi
# shellcheck disable=SC1091
[[ -f ./private_parameters ]] && source ./private_parameters


#Language support.
# shellcheck disable=SC1090
source "${msg_dir:-./lib/msg/}/${LANG_INSTALLER:-en}.sh"

print_param note "$M_WELCOME"

if [[ $LIVE_MODE == "1" ]]; then
  CONFIG_FILE="/tmp/last_gen.sh"
  add_var "declare -gx" "dir" "${DEFAULT_DIR:-"/mnt/mnt"}"
else
  print_param note "$M_DIR_WARN\n$M_PROFILE_1 $CONFIG_FILE"
  read_param "" "$M_PATH" "${DEFAULT_DIR:-"/mnt/mnt"}" dir text
fi

# shellcheck disable=SC2046
read_param "$M_DISTR_1:\n" "$M_DISTR_2" "$DEFAULT_DISTR" distr menu_var $(list_files "./lib/distr/" -type d | gen_menu)

# shellcheck disable=SC1091
source ./lib/common/common_options.sh
# shellcheck disable=SC1090
source "./lib/distr/${distr:?}/distr_options.sh"
#Final menu for changes.
var_final=''
until [[ $var_final == "0" ]]; do
  #Make menu, We use array to make parametres.
  vars_list=("0" "$M_LIST_FINAL_END_OPTION")
  # shellcheck disable=SC2154
  for ((i=0; i<${#var_num[@]}; i++)); do
    var=${var_num[i]}
    [[ $var == "var_final" ]] && continue
    vars_list=("${vars_list[@]}" "$((i+1))")
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
  if [[ $var_final != "0" ]]; then
    var="${var_num[$((${var_final#0}-1))]}"
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

{
  echo -e "#Generated on $(date -u).\n"
  var_export "add_var "
} > "$CONFIG_FILE"

# =)
echo "$M_NICE"
exit 0
