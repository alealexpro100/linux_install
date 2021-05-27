#XBPS setup.
msg_print note "XBPS setup..."
xbps_install="xbps-install -y"

msg_print note 'Configuring xbps.d...'
cp /usr/share/xbps.d/*-*-*.conf /etc/xbps.d/
for file in /etc/xbps.d/*; do
  [[ -e "$file" ]] || break
  sed -ie "s|https://alpha.de.repo.voidlinux.org/current|$mirror_voidlinux|" "$file"
done
rm -rf /etc/xbps.d/install_repo.conf
xbps-install -S

msg_print note "XBPS is ready."

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
  if [[ $pipewire == "1" ]]; then
    to_install="$to_install pipewire alsa-pipewire"
  fi
fi

[[ -n $to_install ]] && $xbps_install $to_install
for service in $to_enable; do
    [[ ! -d "/etc/runit/runsvdir/default/$service" ]] && ln -s "/etc/sv/$service" /etc/runit/runsvdir/default/
done

msg_print note "Packages installed."