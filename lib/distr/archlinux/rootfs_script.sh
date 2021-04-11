#Pacman setup.
msg_print note "Pacman setup..."
pacman_install="pacman -Suy --needed --noconfirm"

sed -i "s/#Color/Color/" /etc/pacman.conf
[[ $arch_add_i386 == "1" ]] && sed -ie '$!N;s|\#\[multilib\]\n\#Include|\[multilib\]\nInclude|;P;D' /etc/pacman.conf #>_<
mv /etc/pacman.d/mirrorlist{,.pacnew}
mv /etc/pacman.d/mirrorlist{.used,}

msg_print note "Pacman is ready."

#Arch setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

if [[ $kernel == "1" ]]; then
  to_install="$to_install linux linux-firmware linux-headers"
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install networkmanager crda"
    to_enable="$to_enable NetworkManager.service"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio pulseaudio-alsa"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluetooth"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluez bluez-utils"
    to_enable="$to_enable bluetooth.service"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install cups cups-filters"
    to_enable="$to_enable cups.socket"
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
            plasma) to_install="$to_install plasma kde-applications";;
            xfce4) to_install="$to_install xfce4 xfce4-goodies";;
            cinnamon) to_install="$to_install cinnamon";;
            gnome) to_install="$to_install gnome gnome-extra";;
            *) return_err "Incorrect paramater desktop_de=$desktop_de! Mistake?";;
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
        ;;
        WM)
          to_install="$to_install archlinux-xdg-menu"
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
      to_enable="$to_enable gdm.service"
    ;;
    lightdm)
      to_install="$to_install lightdm-gtk-greeter-settings"
      to_enable="$to_enable lightdm.service"
    ;;
    sddm)
      to_install="$to_install sddm"
      to_enable="$to_enable sddm.service"
    ;;
    *) 
      return_err "Incorrect paramater desktop_dm=$desktop_dm! Mistake?"
    ;;
  esac
fi

[[ -n "$to_install" ]] && $pacman_install $to_install
for service in $to_enable; do
  systemctl enable "$service"
done

msg_print note "Packages are installed."