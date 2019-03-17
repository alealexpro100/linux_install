#!/bin/bash

#Preconfiguration
set -e
cd /root/
echo 'Getting configuration...'
if [[ -z /root/configuration ]]; then
  echo '[ERROR] No configuration file! Exiting.'
  exit 1
else
  source /root/configuration
fi

echo 'Setting up hostname...'
rm -rf /etc/hostname
echo $hostname >> /etc/hostname

echo 'Changing root password...'
echo "root:$passwd" | chpasswd -c SHA512

echo "Creating user $user_name..."
groupadd ssh
useradd -m -g users -G wheel,ssh -s /bin/bash $user_name
echo  "$user_name:$passwd" | chpasswd -c SHA512

echo "Setting up sudo..."
sed "82s/# %wheel/%wheel/" /etc/sudoers >> /etc/sudoers.new
mv /etc/sudoers{.new,}

echo 'Configuring xbps.d...'
cp /usr/share/xbps.d/*-*-*.conf /etc/xbps.d/
for file in $(ls /etc/xbps.d/); do
  sed -e "s|https://alpha.de.repo.voidlinux.org/current|$mirror_voidlinux|" /etc/xbps.d/$file >> /etc/xbps.d/$file.new
  mv /etc/xbps.d/$file{.new,}
done
rm -rf /etc/xbps.d/install_repo.conf

echo "Installing addational packages..."
xbps-install -Sy nano
if [[ $networkmanager == "1" ]]; then
  xbps-install -Sy NetworkManager
  ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
  ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
fi
sed -e 's/#FONT="lat9w-16"/FONT="ter-v16n"/' /etc/rc.conf >> /etc/rc.conf.new
mv /etc/rc.conf{.new,}

if [[ $kernel == "1" ]]; then
  echo "Installing kernel and system tools..."
  xbps-install -Sy linux base-system
fi

if [[ $graph == "1" ]]; then
  echo 'Installing graphics packages...'
  xbps-install -Sy xorg lightdm-gtk-greeter-settings xfce4 pulseaudio pavucontrol
  [[ $networkmanager == 1 ]] && xbps-install -Sy network-manager-applet
fi

if [[ $grub2 == "1" ]]; then
  xbps-install -Sy grub
  [[ $flash_disk == 1 ]] && echo "Os-prober can't be removed"
fi

rm -rf /root/pi_s1.sh
