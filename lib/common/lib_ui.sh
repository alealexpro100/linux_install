#!/bin/bash

declare -A var_history_list=()
declare -A var_history_num=()
var_history_index=$((0))

#Weight and height parametres of terminal for UI.
ui_terminal_weight=$(($(stty size | awk '{print $1;}')*5/10)) ui_terminal_height=$(($(stty size | awk '{print $2;}')*5/10))

#Generate menu.
function gen_menu() {
  local tmp_gen_menu=() i=0
  while IFS=$'\n' read -r var; do
    tmp_gen_menu=("${tmp_gen_menu[@]}" "$((i++))" "$var")
  done
  echo -ne "${tmp_gen_menu[@]@Q}"
}

#Print info
function print_param() {
case $ECHO_MODE in
    whiptail|dialog) 
      local print_type=$1 text="$2"
      local options=("$ECHO_MODE" "--cancel-button" "$M_CANCEL_BUTTON" "--backtitle" "$M_PROJECT_NAME")
      "${options[@]}" --msgbox "$text$dialog" $ui_terminal_weight $ui_terminal_height
    ;;
    auto|cli|*) 
        local print_type=$1 text="$2"
        msg_print "$print_type" "$text"
    ;;
  esac
}

function history_read_param() {
  [[ $1 != 0 ]] || return_err "Operation cancelled by user!"
  local params=() var
  #Based on https://superuser.com/questions/1066455.
  eval 'for var in '"${var_history_list[${var_history_num[$1]}]}"'; do params=("${params[@]}" "${var}"); done'
  _=$((var_history_index--))
  read_param "${params[@]}"
  _=$((var_history_index++))
}

#Enter parametres.
function read_param() {
  local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
  if [[ ( -z ${var_history_list[$var]} || -z ${var_history_num[$var_history_index]} ) && $NO_HISTORY != "1" ]]; then
    _=$((var_history_index++))
    var_history_num[$var_history_index]=$var;
    var_history_list[$var]=${*@Q}
  fi
  shift 5
  case $ECHO_MODE in
    auto)
      case $option in
        print) echo -ne "$text$dialog";;
        yes_or_no) tmp=1;;
        no_or_yes) tmp=0;;
        text) tmp=$default_var;;
        text_empty) tmp=$default_var;;
        secret) tmp=$default_var;;
        secret_empty) tmp=$default_var;;
        menu) tmp=$default_var;;
        menu_var)
          eval 'for i_var in '"$*"'; do params=("${params[@]}" "${i_var}"); done'
          for ((i=1; i<=${#params[@]}; i+=2)); do
              [[ "${params[$((i))]}" == "$default_var" ]] && default_var=$((i/2)) && break
          done
          tmp="${params[$((default_var*2+1))]}"
        ;;
        *) return_err "Option $option is incorrect!";;
      esac
    ;;
    whiptail|dialog)
      local options=("$ECHO_MODE" "--cancel-button" "$M_CANCEL_BUTTON" "--backtitle" "$M_PROJECT_NAME") return_code='' 
      local params=() i_var
      eval 'for i_var in '"$*"'; do params=("${params[@]}" "${i_var}"); done'
      while [[ $return_code != 0 ]]; do
        case $option in
          yes_or_no)
            tmp=$("${options[@]}" --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "1" "$M_YES" "0" "$M_NO" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          no_or_yes)
            tmp=$("${options[@]}" --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "0" "$M_NO" "1" "$M_YES" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          text)
            while [[ $tmp == '' ]]; do
              tmp=$("${options[@]}" --inputbox "$text$dialog:" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
              [[ $return_code != 0 ]] && break
            done
          ;;
          text_empty)
            tmp=$("${options[@]}" --inputbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          secret)
            while [[ $tmp == '' ]]; do
              tmp=$("${options[@]}" --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
              [[ $return_code != 0 ]] && break
            done
          ;;
          secret_empty)
            tmp=$("${options[@]}" --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          menu)
            tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" $ui_terminal_weight $ui_terminal_height $((ui_terminal_height/7)) "${params[@]}" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
          ;;
          menu_var)
            for ((i=1; i<=${#params[@]}; i+=2)); do
              [[ "${params[$((i))]}" == "$default_var" ]] && default_var=$((i/2)) && break
            done
            tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" $ui_terminal_weight $ui_terminal_height $((ui_terminal_height/7)) "${params[@]}" 3>&1 1>&2 2>&3) && return_code=$? || return_code=$?
            tmp="${params[$((tmp*2+1))]}"
          ;;
          *)
            return_err "Option $option is incorrect!"
          ;;
        esac
        [[ $return_code != 1 ]] || history_read_param "$((var_history_index-1))"
      done
    ;;
    cli|'')
      local params=() i_var
      eval 'for i_var in '"$*"'; do params=("${params[@]}" "${i_var}"); done'
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
  if [[ -n "$tmp" ]]; then
    add_var "declare -gx" "$var" "$tmp"
  else
    add_var "unset" "$var"
  fi
}