 
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

to_install='' to_enable=''
if [[ $kernel == "1" ]]; then
  to_install="$to_install linux-firmware linux-lts"
fi
if [[ $networkmanager == "1" ]]; then
  to_install="$to_install networkmanager networkmanager-openrc"
  to_enable="$to_enable networkmanager"
fi
$apk_install $to_install
for service in $to_enable; do
  rc-update add $service default
done
[[ $networkmanager == "1" ]] &&  addgroup $user_name plugdev

msg_print note "Packages are installed."