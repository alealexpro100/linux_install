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
echo $hostname >> /etc/hostname

echo 'Changing root password...'
echo "root:$passwd" | chpasswd

echo "Creating user $user_name..."
groupadd ssh
useradd -m -g users -G wheel,ssh -s /bin/bash $user_name
echo  "$user_name:$passwd" | chpasswd

echo "Setting up sudo..."
sed "82s/# %wheel/%wheel/" /etc/sudoers >> /etc/sudoers.new
mv /etc/sudoers{.new,}

if [[ $void_add_i386 == "1" && ! $version_void == "musl" ]]; then
  echo "Adding i386 arch..."
  xbps-install -Sy void-repo-multilib
fi

echo "Installing addational packages..."
xbps-install -Sy nano void-repo-nonfree
if [[ $networkmanager == "1" ]]; then
  xbps-install -Sy NetworkManager
  ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
  ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
fi

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel..."
  xbps-install -Sy linux
fi

sed -e '20s/#FONT="lat9w-16"/FONT="ter-v16n"/' /etc/rc.conf >> /etc/rc.conf

if [[ $graph == "1" ]]; then
  echo 'Installing graphics packages...'
  xbps-install -Sy xorg lightdm-gtk-greeter-settings xfce4 pulseaudio pavucontrol
  [[ $networkmanager == 1 ]] && xbps-install -Sy network-manager-applet
fi

if [[ $grub2 == "1" ]]; then
  xbps-install -Sy grub
  [[ $flash_disk == 1 ]] && xbps-remove -y os-prober
fi
