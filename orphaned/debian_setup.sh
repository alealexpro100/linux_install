if [[ $pulseaudio == "1" ]]; then
  to_install="$to_install pulseaudio"
  [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-module-bluetooth"
fi
if [[ $bluetooth == "1" ]]; then
  to_install="$to_install bluetooth"
fi
if [[ $printers == "1" && 0 == 1 ]]; then
  to_install="$to_install task-print-server printer-driver-all"
  to_install="$to_install foomatic-db cups-pdf"
  [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
fi

#---

if [[ $graphics == "1" ]]; then
  echo 'Installing graphics packages...'
  to_install='' to_disable=''
  if [[ $graphics_type == xorg ]]; then
    to_install="$to_install task-desktop"
    if [[ $desktop_type == "DE" ]]; then
      case $desktop_de in
        plasma) to_install="$to_install task-kde-desktop";;
        xfce4) to_install="$to_install task-xfce-desktop";;
        cinnamon) to_install="$to_install task-cinnamon-desktop";;
        gnome) to_install="$to_install task-gnome-desktop";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      if [[ $pulseaudio == "1" ]]; then
        case $desktop_de in 
          xfce4) to_install="$to_install pavucontrol";;
        esac
      fi
      if [[ $bluetooth == "1" ]]; then
        case $desktop_de in 
          xfce4|cinnamon) to_install="$to_install blueman";;
        esac
      fi
    else
      case $desktop_wm in
        icewm) to_install="$to_install icewm";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      to_install="$to_install menu"
      [[ $pulseaudio == "1" ]] && to_install="$to_install pulsemixer"
    fi
  else
    msg_print error "Wayland is not supported now!"
  fi
  #[[ $firefox_soft == "1" ]] && to_install="$to_install firefox"
  #[[ $chromium_soft == "1" ]] && to_install="$to_install chromium"
  #[[ $office_soft == "1" ]] && to_install="$to_install libreoffice-fresh poppler poppler-data scribus xreader"
  #[[ $admin_soft == "1" ]] && to_install="$to_install gparted gpart exfat-utils dosfstools ntfs-3g"
  if [[ $dm_install == "0" ]]; then
    case $desktop_de in
      plasma) to_disable="$to_disable sddm.service";;
      xfce4) to_disable="$to_disable lightdm.service";;
      cinnamon|gnome) to_disable="$to_disable gdm.service";;
    esac
  fi
  $apt_install $to_install
  for service in $to_disable; do
    systemctl enable $service
  done
fi