
#Weight and height parametres of terminal for UI.
ui_terminal_weight=$(($(stty size | awk '{print $1;}')*5/10)) ui_terminal_height=$(($(stty size | awk '{print $2;}')*5/10))

#Print info
case $ECHO_MODE in
  whiptail|dialog) 
    function print_param() {
      local print_type=$1 text="$2"
      local options="$ECHO_MODE --cancel-button $M_EXIT_BUTTON"
      $options --msgbox "$text$dialog" $ui_terminal_weight $ui_terminal_height
    }
  ;;
  auto|cli|*) 
    function print_param() {
      local print_type=$1 text="$2"
      msg_print "$print_type" "$text"
    }
  ;;
esac

#Enter parametres. Needs rework!
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
        menu) tmp=$default_var;;
        *) return_err "Option $option is incorrect!";;
      esac
      add_var "declare -gx" "$var" "$tmp"
    }
  ;;
  whiptail|dialog)
    function read_param() {
      local text="$1" dialog="$2" default_var=$3 var=$4 option=$5 tmp=''
      local options="$ECHO_MODE --cancel-button $M_EXIT_BUTTON"
      shift 5 #See 'menu' section
      case $option in
        yes_or_no)
          tmp=$($options --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "1" "$M_YES" "0" "$M_NO" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        no_or_yes)
          tmp=$($options --menu "$text$dialog" $ui_terminal_weight $ui_terminal_height 2 "0" "$M_NO" "1" "$M_YES" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        text)
          while [[ $tmp == '' ]]; do
            tmp=$($options --inputbox "$text$dialog:" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        text_empty)
          tmp=$($options --inputbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        secret)
          while [[ $tmp == '' ]]; do
            tmp=$($options --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
          done
        ;;
        secret_empty)
          tmp=$($options --passwordbox "$text$dialog" $ui_terminal_weight $ui_terminal_height "$default_var" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
        ;;
        menu)
          tmp=$($options --menu "$text$dialog:" $ui_terminal_weight $ui_terminal_height $((ui_terminal_height/7)) "$@" 3>&1 1>&2 2>&3) || return_err "Operation cancelled by user!"
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
      shift 5 #See 'menu' section
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
          while [[ $tmp == '' ]]; do
            echo -ne "$text"
            for ((i=1; i<$#; i+=2)); do
              j=$((i+1))
              echo -e "${!i} ${!j}";
            done
            read -r -p "$dialog: " -e -i "$default_var" tmp
          done
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