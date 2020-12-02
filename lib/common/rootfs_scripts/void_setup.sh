msg_print note "Installing addational packages..."
xbps-install -Sy nano
if [[ $networkmanager == "1" ]]; then
  xbps-install -Sy NetworkManager
  ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
  ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
fi
if [[ $kernel == "1" ]]; then
  msg_print note "Installing kernel and system tools..."
  xbps-install -Sy linux base-system
  sed -ie 's/#FONT="lat9w-16"/FONT="ter-v16n"/' /etc/rc.conf
fi

if [[ $graph == "1" ]]; then
  msg_print note 'Installing graphics packages...'
  xbps-install -Sy xorg lightdm-gtk-greeter-settings xfce4 pulseaudio pavucontrol
  [[ $lightdm_autostart == 1 ]] && ln -s /etc/sv/lightdm /etc/runit/runsvdir/default/
  [[ $networkmanager == 1 ]] && xbps-install -Sy network-manager-applet
fi
