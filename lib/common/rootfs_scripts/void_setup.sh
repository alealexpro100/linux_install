
#Void setup.
msg_print note "Installing addational packages..."

if [[ $kernel == "1" ]]; then
  msg_print note "Installing kernel and system tools..."
  $xbps_install linux base-system
  sed -ie 's/#FONT="lat9w-16"/FONT="ter-v16n"/' /etc/rc.conf
fi

if [[ $networkmanager == "1" ]]; then
  $xbps_install NetworkManager
  ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
  ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
fi

msg_print note "Packages installed."