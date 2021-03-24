
#Voidlinux
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi


if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install NetworkManager"
    to_enable="$to_enable NetworkManager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install alsa-plugins-pulseaudio"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluez"
    to_enable="$to_enable bluetoothd"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install cups cups-filters"
    to_enable="$to_enable cupsd"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

if [[ $graphics == "1" ]]; then
  case $graphics_type in
    xorg)
      to_install="$to_install xorg xorg-drivers"
      case $desktop_type in
        DE)
          case $desktop_de in
            plasma) to_install="$to_install kde5 kde5-applications";;
            xfce4) to_install="$to_install xfce4";;
            cinnamon) to_install="$to_install cinnamon";;
            gnome) to_install="$to_install gnome gnome-apps";;
            *) return_err "Incorrect paramater desktop_de=$desktop_de! Mistake?";;
          esac
          if [[ $pulseaudio == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon|gnome) to_install="$to_install pavucontrol";;
            esac
          fi
          if [[ $bluetooth == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon) to_install="$to_install gnome-bluetooth";;
            esac
          fi
        ;;
        WM)
          to_install="$to_install"
          case $desktop_wm in
            icewm) to_install="$to_install icewm";;
            *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
          esac
          [[ $pulseaudio == "1" ]] && to_install="$to_install pulsemixer"
        ;;
        *)
          return_err "Wrong parameter desktop_type=$desktop_type. Mistake?"
        ;;
      esac
    ;;
    wayland)
      return_err "WAYLAND IS NOT SUPPORTED! Mistake?"
    ;;
    *)
      return_err "Wrong parameter graphics_type=$graphics_type. Mistake?"
    ;;
  esac
  case $desktop_dm in
    gdm) to_install="$to_install gdm" to_enable="$to_enable gdm";;
    lightdm) to_install="$to_install lightdm-gtk-greeter-settings" to_enable="$to_enable lightdm";;
    sddm) to_install="$to_install sddm" to_enable="$to_enable sddm";;
    *) return_err "Incorrect paramater desktop_dm=$desktop_dm! Mistake?";;
  esac
fi


#Alpine
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install networkmanager networkmanager-openrc"
    to_enable="$to_enable networkmanager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio pulseaudio-alsa"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluez"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluez"
    to_enable="$to_enable bluetooth"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install cups cups-filters"
    to_enable="$to_enable cupsd"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

#Debian
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install network-manager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-module-bluetooth"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluetooth"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install task-print-server printer-driver-all"
    to_install="$to_install foomatic-db cups-pdf"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

if [[ $graphics == "1" ]]; then
  case $graphics_type in
    xorg)
      to_install="$to_install task-desktop"
      case $desktop_type in
        DE)
          case $desktop_de in
            plasma) to_install="$to_install task-kde-desktop";;
            xfce4) to_install="$to_install task-xfce-desktop";;
            cinnamon) to_install="$to_install task-cinnamon-desktop";;
            gnome) to_install="$to_install task-gnome-desktop";;
            *) return_err "Incorrect paramater desktop_de=$desktop_de! Mistake?";;
          esac
          if [[ $pulseaudio == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon|gnome) to_install="$to_install pavucontrol";;
            esac
          fi
          if [[ $bluetooth == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon) to_install="$to_install blueman";;
            esac
          fi
        ;;
        WM)
          to_install="$to_install menu"
          case $desktop_wm in
            icewm) to_install="$to_install icewm";;
            *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
          esac
          [[ $pulseaudio == "1" ]] && to_install="$to_install pulsemixer"
        ;;
        *)
          return_err "Wrong parameter desktop_type=$desktop_type. Mistake?"
        ;;
      esac
    ;;
    wayland)
      return_err "WAYLAND IS NOT SUPPORTED! Mistake?"
    ;;
    *)
      return_err "Wrong parameter graphics_type=$graphics_type. Mistake?"
    ;;
  esac
  case $desktop_dm in
    gdm)
      to_install="$to_install gdm"
    ;;
    lightdm)
      to_install="$to_install lightdm-gtk-greeter-settings"
    ;;
    sddm)
      to_install="$to_install sddm"
    ;;
    *) return_err "Incorrect paramater desktop_dm=$desktop_dm! Mistake?";;
  esac
fi
