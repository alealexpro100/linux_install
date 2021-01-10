 
#Arch setup.
msg_print note "Installing addational packages..."

to_install='' to_enable=''
if [[ $kernel == "1" ]]; then
  to_install="$to_install linux linux-firmware linux-headers"
fi
if [[ $networkmanager == "1" ]]; then
  to_install="$to_install networkmanager crda"
  to_enable="$to_enable NetworkManager.service"
fi
$pacman_install $to_install
for service in $to_enable; do
  systemctl enable $service
done

msg_print note "Packages are installed."