#!/bin/bash

#Weight and height parametres of terminal for UI.
ui_terminal_weight=$(($(stty size | awk '{print $1;}')*5/10)) ui_terminal_height=$(($(stty size | awk '{print $2;}')*5/10))

function gen_menu() {
  local vars_list=() i=0
  while IFS=$'\n' read -r var; do
    vars_list=("${vars_list[@]}" "$((i++))" "$var")
  done
  echo "${vars_list[@]}"
}

#Print info
function print_param() {
case $ECHO_MODE in
    whiptail|dialog) 
      local print_type=$1 text="$2"
      local options=("$ECHO_MODE" "--cancel-button" "$M_EXIT_BUTTON" "--backtitle" "$M_PROJECT_NAME")
      "${options[@]}" --msgbox "$text$dialog" $ui_terminal_weight $ui_terminal_height
    ;;
    auto|cli|*) 
        local print_type=$1 text="$2"
        msg_print "$print_type" "$text"
    ;;
  esac
}

#Enter parametres. Needs rework!
function read_param() {
  local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
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
          for ((i=0; i<=$#; i+=2)); do
            if [[ "${!i}" == "$default_var" ]]; then
              default_var=$((i/2-1))
              break
            fi
          done
          tmp=$(((default_var+1)*2))
          tmp="${!tmp}"
        ;;
        *) return_err "Option $option is incorrect!";;
      esac
    ;;
    whiptail|dialog)
      local options=("$ECHO_MODE" "--cancel-button" "$M_EXIT_BUTTON" "--backtitle" "$M_PROJECT_NAME")
      case $option in
        yes_or_no)
          tmp=$("${options[@]}" --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "1" "$M_YES" "0" "$M_NO" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        no_or_yes)
          tmp=$("${options[@]}" --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "0" "$M_NO" "1" "$M_YES" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        text)
          while [[ $tmp == '' ]]; do
            tmp=$("${options[@]}" --inputbox "$text$dialog:" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        text_empty)
          tmp=$("${options[@]}" --inputbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        secret)
          while [[ $tmp == '' ]]; do
            tmp=$("${options[@]}" --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        secret_empty)
          tmp=$("${options[@]}" --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        menu)
          tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" $ui_terminal_weight $ui_terminal_height $((ui_terminal_height/7)) "$@" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        menu_var)
          for ((i=0; i<=$#; i+=2)); do
            if [[ "${!i}" == "$default_var" ]]; then
              default_var=$((i/2-1))
              break
            fi
          done
          tmp=$("${options[@]}" --default-item "${default_var:-0}" --menu "$text$dialog:" $ui_terminal_weight $ui_terminal_height $((ui_terminal_height/7)) "$@" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          tmp=$(((tmp+1)*2))
          tmp="${!tmp}"
        ;;
        *)
          return_err "Option $option is incorrect!"
        ;;
      esac
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
            for ((i=1; i<$#; i+=2)); do
              j=$((i+1))
              echo -e "${!i} ${!j}"
            done
            read -r -p "$dialog: " -e -i "$default_var" tmp
            for ((i=1; i<$#; i+=2)); do
              if [[ $tmp == $((i/2)) ]]; then
                correct=1
                break
              fi
            done
          done
        ;;
        menu_var)
          for ((i=0; i<=$#; i+=2)); do
            if [[ "${!i}" == "$default_var" ]]; then
              default_var=$((i/2-1))
              break
            fi
          done
          local correct=0;
          while [[ "$correct" != "1" ]]; do
            echo -ne "$text"
            for ((i=1; i<$#; i+=2)); do
              j=$((i+1))
              echo -e "${!i} ${!j}"
            done
            read -r -p "$dialog: " -e -i "$default_var" tmp
            for ((i=1; i<$#; i+=2)); do
              j=$((i+1))
              [[ $tmp == "${!i}" ]] && tmp=${!j}
              if [[ $tmp == "${!j}" ]]; then
                correct=1
                break
              fi
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
  add_var "declare -gx" "$var" "$tmp"
}