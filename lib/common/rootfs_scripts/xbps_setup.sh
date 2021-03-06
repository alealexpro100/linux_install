
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