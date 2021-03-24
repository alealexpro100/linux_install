 
#Alpine setup.
msg_print note "Installing addational packages..."

#Activate services for booting
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit
rc-update add hwdrivers sysinit
rc-update add modloop sysinit
rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc boot
rc-update add syslog boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown
rc-update add firstboot default

#Network setup.
echo -e "auto lo\n\tiface lo inet loopback\n" > /etc/network/interfaces
echo -e "#auto eth0\n#  iface eth0 inet dhcp\n#  iface eth0 inet6 auto\n" >> /etc/network/interfaces


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
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio pulseaudio-alsa"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluez"
  fi
fi

[[ -n "$to_install" ]] && $apk_install $to_install
for service in $to_enable; do
  rc-update add "$service" default
done
[[ $networkmanager == "1" ]] &&  addgroup "$user_name" plugdev

msg_print note "Packages are installed."