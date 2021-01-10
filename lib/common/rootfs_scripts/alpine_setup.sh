 
#Alpine setup.
msg_print note "Installing addational packages..."

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