
# Soft install.
msg_print note "Installing soft..."

to_install="" to_enable=""
case $distr in
  alpine)
    to_install="$to_install dbus"
    to_enable="$to_enable dbus"
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
      [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
    fi
    $apk_install $to_install
    for service in $to_enable; do
      rc-update add $service default
    done
  ;;
  archlinux) 
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
    $pacman_install $to_install
  ;;
  debian)
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
    $apt_install $to_install
    for service in $to_enable; do
      systemctl enable $service
    done
  ;;
  voidlinux)
    to_install="$to_install dbus"
    to_enable="$to_enable dbus"
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
    $xbps_install $to_install
    for service in $to_enable; do
      [[ ! -d "/etc/runit/runsvdir/default/$service" ]] && ln -s "/etc/sv/$service" /etc/runit/runsvdir/default/
    done
  ;;
  *)
  msg_print error "Soft installation is not supported for $distr. Skipping."
  ;;
esac

msg_print note "Installed soft."