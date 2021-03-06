 
#Arch setup.
msg_print note "Installing addational packages..."

to_install='' to_enable=''

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

[[ -n "$to_install" ]] && $pacman_install $to_install
for service in $to_enable; do
  systemctl enable "$service"
done

msg_print note "Packages are installed."