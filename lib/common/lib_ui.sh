#!/bin/bash

# History variables. Array contains full `read_param` options. Variable contains actual index.
var_history_list=()
var_history_index=$((0))
ui_terminal=[]

# Weight and height parametres of terminal for UI.
# We will recalculate it each time.
function calc_ui_terminal() {
  read -a ui_terminal < <(stty size)
  ui_terminal[0]=$((ui_terminal[0]/2)) ui_terminal[1]=$((ui_terminal[1]/2))
}

# Generate menu. Reads by lines and return array of it.
# Used for whiptail or dialog in read_params to show menus.
# Example: "$(gen_menu < <(echo -e "glibc\nmusl"))"
function gen_menu() {
  local tmp_gen_menu=() i=0
  while IFS=$'\n' read -r var; do
    tmp_gen_menu=("${tmp_gen_menu[@]}" "$((i++))" "$var")
  done
  echo -ne "${tmp_gen_menu[@]@Q}"
}

# Print info
# Use it with read_param.
# Please do not use `msg_print` by yourself in user-mode step.
# Syntax: print_param {note|warn|err|*} [TEXT]
# Example: print_param note "Your carrot is here."
function print_param() {
case $ECHO_MODE in
    whiptail|dialog)
      calc_ui_terminal
      local print_type=$1 text="$2" dialog="$3"
      local options=("$ECHO_MODE" "--cancel-button" "$M_CANCEL_BUTTON" "--backtitle" "$M_PROJECT_NAME $LI_VERSION.")
      "${options[@]}" "--msgbox" "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]}
    ;;
    auto|cli|*) 
      local print_type=$1 text="$2$3"
      msg_print "$print_type" "$text"
    ;;
  esac
}

# Function to go back in history. Uses eval, but still pretty safe.
# This function is recursive, so be cautious when editing it.
function history_read_param() {
  [[ $1 != "0" ]] || return_err "Operation cancelled by user!"
  local params_h=() i_var
  #Based on https://superuser.com/questions/1066455.
  eval 'for i_var in '"${var_history_list[$1]}"'; do params_h=("${params_h[@]}" "${i_var}"); done'
  _=$((var_history_index--))
  read_param "${params_h[@]}"
}

# Enter parameters.
# Supported modes: 
# * auto (no user input);
# * cli (for plain terminals or automation);
# * whiptail or dialog (recommended, handy to use).
# Mode 'cli' is default because its good compatibility.
# Only whiptail or dialog mode has support for using history.
# Other modes still write history.
# Options:
# * NO_HISTORY=1 - Prevents current command to be kept in history. Does not affect variable set.
# * NO_VAR=1 - Do not set variable in local environment. From function `add_var`.
# Syntax: read_param [TEXT] [DIALOG] {0-99} [VARIABLE] {yes_or_no|no_or_yes|text|text_empty|secret|secret_empty|menu|menu_var} [ADDITIONAL_PARAMS]
# Example 1: read_param "" "${M_VAR_DESCRIPTION[$var]:-$var}" "" "$var" yes_or_no
# Example 2: NO_VAR=1 NO_HISTORY=1 read_param "$M_DEB_REPO_TEXT\n" "$M_LIST_DIALOG" "0" repos menu "$(gen_menu < <(echo -e "$vars_list"))"
function read_param() {
  # shellcheck disable=SC2034
  local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp='' i_var params=() params_h=()
  [[ $NO_HISTORY == "1" ]] || eval 'for i_var in '"${*@Q}"'; do params_h=("${params_h[@]}" "${i_var}"); done'
  shift 5
  eval 'for i_var in '"$*"'; do params=("${params[@]}" "${i_var}"); done'
  case $ECHO_MODE in
    auto)
      case $option in
        yes_or_no) tmp=1;;
        no_or_yes) tmp=0;;
        text|text_empty|secret|secret_empty|menu) tmp=$default_var;;
        menu_var) 
          for ((i=0; i<=${#params[@]}; i+=2)); do
              if [[ "${params[$((i))]}" == "$default_var" ]]; then
                tmp=${params[$((i+1))]}
                break
              fi
          done
          [[ -z $tmp ]] && tmp="$default_var"
        ;;
        *) return_err "Option $option is incorrect!";;
      esac
    ;;
    whiptail|dialog)
      calc_ui_terminal
      local options=("$ECHO_MODE" "--cancel-button" "$M_CANCEL_BUTTON" "--backtitle" "$M_PROJECT_NAME $LI_VERSION.") return_code='' 
      while [[ $return_code != 0 ]]; do
        case $option in
          yes_or_no)
            tmp=$("${options[@]}" --menu "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]} 2 "1" "$M_YES" "0" "$M_NO" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          no_or_yes)
            tmp=$("${options[@]}" --menu "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]} 2 "0" "$M_NO" "1" "$M_YES" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          text)
            while [[ $tmp == '' ]]; do
              tmp=$("${options[@]}" --inputbox "$text$dialog:" ${ui_terminal[0]} ${ui_terminal[1]} "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
              [[ $return_code != 0 ]] && break
            done
          ;;
          text_empty)
            tmp=$("${options[@]}" --inputbox "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]} "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          secret)
            while [[ $tmp == '' ]]; do
              tmp=$("${options[@]}" --passwordbox "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]} "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
              [[ $return_code != 0 ]] && break
            done
          ;;
          secret_empty)
            tmp=$("${options[@]}" --passwordbox "$text$dialog" ${ui_terminal[0]} ${ui_terminal[1]} "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          menu)
            tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" ${ui_terminal[0]} ${ui_terminal[1]} $((ui_terminal[1]/7)) "${params[@]}" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          menu_var)
            for ((i=1; i<=${#params[@]}; i+=2)); do
              [[ "${params[$((i))]}" == "$default_var" ]] && default_var=$((i/2)) && break
            done
            tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" ${ui_terminal[0]} ${ui_terminal[1]} $((ui_terminal[1]/7)) "${params[@]}" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
            tmp="${params[$((tmp*2+1))]}"
          ;;
          *)
            return_err "Option $option is incorrect!"
          ;;
        esac
        [[ $return_code != 1 ]] || history_read_param "$((var_history_index))"
      done
    ;;
    cli|'')
      case $option in
        yes_or_no)
          while [[ $tmp == '' ]]; do
            echo -ne "$text"
            read -r -p "$dialog (Y/n): " -e -i "$default_var" tmp
            case "$tmp" in
              ''|[yY]|[yY][eE][sS]) tmp=1;;
              [nN]|[nN][oO]) tmp=0;;
              *) tmp='';;
            esac
          done
        ;;
        no_or_yes)
          while [[ $tmp == '' ]]; do
            echo -ne "$text"
            read -r -p "$dialog (N\y): " -e -i "$default_var" tmp
            case "$tmp" in
              [yY]|[yY][eE][sS]) tmp=1;;
              ''|[nN]|[nN][oO]) tmp=0;;
              *) tmp='';;
            esac
          done
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
        menu)
          local correct=0;
          while [[ "$correct" != "1" ]]; do
            echo -ne "$text"
            for ((i=0; i<${#params[@]}; i+=2)); do
              echo -e "${params[$((i))]} ${params[$((i+1))]}"
            done
            read -r -p "$dialog: " -e -i "$default_var" tmp
            for ((i=0; i<${#params[@]}; i+=2)); do
              [[ $tmp == "${params[$((i))]}" ]] && correct=1 && break
            done
          done
        ;;
        menu_var)
          for ((i=1; i<=${#params[@]}; i+=2)); do
            [[ "${params[$((i))]}" == "$default_var" ]] && default_var=$((i/2)) && break
          done
          local correct=0;
          while [[ "$correct" != "1" ]]; do
            echo -ne "$text"
            for ((i=0; i<${#params[@]}; i+=2)); do
              echo -e "${params[$((i))]} ${params[$((i+1))]}"
            done
            read -r -p "$dialog: " -e -i "$default_var" tmp
            for ((i=0; i<${#params[@]}; i+=2)); do
              [[ $tmp == "${params[$((i))]}" ]] && tmp=${params[$((i+1))]}
              [[ $tmp == "${params[$((i+1))]}" ]] && correct=1 && break
            done
          done
        ;;
        *)
          return_err "Option $option is incorrect!"
        ;;
      esac
    ;;
    *)
      return_err "Incorrect paramater ECHO_MODE $ECHO_MODE! Mistake?"
    ;;
    esac
  if [[ $NO_HISTORY != "1" ]]; then
    _=$((var_history_index++))
    params_h[2]="$tmp"
    var_history_list[$var_history_index]=${params_h[*]@Q}
  fi
  if [[ -n "$tmp" ]]; then
    add_var "declare -gx" "$var" "$tmp"
  else
    add_var "unset" "$var"
  fi
}