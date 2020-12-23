if [[ $pulseaudio == "1" ]]; then
  to_install="$to_install pulseaudio pulseaudio-alsa"
  [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluetooth"
fi
if [[ $bluetooth == "1" ]]; then
  to_install="$to_install bluez bluez-utils"
  to_enable="$to_enable bluetooth.service"
fi
if [[ $printers == "1" ]]; then
  to_install="$to_install cups foomatic-db-engine foomatic-db print-manager system-config-printer"
  to_install="$to_install foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds"
  to_install="$to_install foomatic-db-ppds cups-pdf cups-filters gutenprint"
  [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  to_enable="$to_enable cups.socket"
fi 

#---

if [[ $graphics == "1" ]]; then
  echo 'Installing graphics packages...'
  to_install='' to_enable=''
  if [[ $graphics_type == xorg ]]; then
    to_install="$to_install xorg xorg-drivers ttf-droid"
    if [[ $desktop_type == "DE" ]]; then
      case $desktop_de in
        plasma) to_install="$to_install plasma kde-applications";;
        xfce4) to_install="$to_install xfce4 xfce4-goodies";;
        cinnamon) to_install="$to_install cinnamon";;
        gnome) to_install="$to_install gnome gnome-extra";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      if [[ $pulseaudio == "1" ]]; then
        case $desktop_de in 
          xfce4|cinnamon|gnome) to_install="$to_install pavucontrol";;
        esac
      fi
      if [[ $bluetooth == "1" ]]; then
        case $desktop_de in 
          xfce4|cinnamon) to_install="$to_install blueberry";;
        esac
      fi
    else
      case $desktop_wm in
        icewm) to_install="$to_install icewm";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      to_install="$to_install archlinux-xdg-menu"
      [[ $pulseaudio == "1" ]] && to_install="$to_install pulsemixer"
    fi
  else
    msg_print error "Wayland is not supported now!"
  fi
  [[ $firefox_soft == "1" ]] && to_install="$to_install firefox"
  [[ $chromium_soft == "1" ]] && to_install="$to_install chromium"
  [[ $office_soft == "1" ]] && to_install="$to_install libreoffice-fresh poppler poppler-data scribus xreader"
  [[ $admin_soft == "1" ]] && to_install="$to_install gparted gpart exfat-utils dosfstools ntfs-3g"
  case $desktop_dm in
    gdm) to_install="$to_install gdm" to_enable="$to_enable gdm.service";;
    lightdm) to_install="$to_install lightdm-gtk-greeter-settings" to_enable="$to_enable lightdm.service";;
    sddm) to_install="$to_install sddm" to_enable="$to_enable sddm.service";;
    *) msg_print error "Incorrect paramater $desktop_dm! Mistake?";;
  esac
  $pacman_install $to_install
  for service in $to_enable; do
    systemctl enable $service
  done
fi