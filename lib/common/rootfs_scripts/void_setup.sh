
#Void setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

if [[ $kernel == "1" ]]; then
  to_install="$to_install linux base-system"
fi

if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install NetworkManager"
    to_enable="$to_enable NetworkManager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install alsa-plugins-pulseaudio"
  fi
fi

[[ -n $to_install ]] && $xbps_install $to_install
for service in $to_enable; do
    [[ ! -d "/etc/runit/runsvdir/default/$service" ]] && ln -s "/etc/sv/$service" /etc/runit/runsvdir/default/
done

msg_print note "Packages installed."