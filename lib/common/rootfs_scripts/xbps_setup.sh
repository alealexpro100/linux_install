
#Pacman setup.
msg_print note "XBPS setup..."

if [[ $version_void == "glibc" ]]; then
  msg_print note "Setting up locales..."
  sed -i "s/#$LANG/$LANG/" /etc/default/libc-locales
  sed -ie "1s/en_US.UTF-8/$LANG/" /etc/locale.conf
  xbps-reconfigure -f glibc-locales
fi

msg_print note 'Configuring xbps.d...'
cp /usr/share/xbps.d/*-*-*.conf /etc/xbps.d/
for file in $(ls /etc/xbps.d/); do
  sed -ie "s|https://alpha.de.repo.voidlinux.org/current|$mirror_voidlinux|" /etc/xbps.d/$file
done
rm -rf /etc/xbps.d/install_repo.conf

msg_print note "XBPS is ready."