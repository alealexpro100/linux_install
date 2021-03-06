#Apk config
msg_print note "Apk setup..."
apk_install="apk add"

[[ -f /etc/apk/repositories ]] && rm -rf /etc/apk/repositories
echo -e "$mirror_alpine/$version_alpine/main\n$mirror_alpine/$version_alpine/community" >> /etc/apk/repositories
apk update

msg_print note "Apk is ready."

#Alpine setup.
msg_print note "Installing addational packages..."

#Activate services for booting
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add hwdrivers sysinit
rc-update add mdev sysinit
rc-update add bootmisc boot
rc-update add hostname boot
rc-update add hwclock boot
rc-update add modules boot
rc-update add networking boot
#rc-update add swap boot
rc-update add sysctl boot
rc-update add syslog boot
rc-update add urandom boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

#Network setup.
echo -e "auto lo\n  iface lo inet loopback\n" > /etc/network/interfaces
echo -e "#auto eth0\n#\tiface eth0 inet dhcp\n#\t\thostname $hostname\n" >> /etc/network/interfaces


to_install="$postinstall" to_enable=''

if [[ $kernel == "1" ]]; then
  to_install="$to_install linux-firmware linux-lts"
fi
if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install networkmanager networkmanager-openrc"
    to_enable="$to_enable networkmanager"
  fi
  if [[ $pipewire == "1" ]]; then
    to_install="$to_install pipewire pipewire-pulse"
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

[[ -n "$to_install" ]] && $apk_install $to_install
for service in $to_enable; do
  rc-update add "$service" default
done
[[ $networkmanager == "1" ]] &&  addgroup "$user_name" plugdev

msg_print note "Packages are installed."
