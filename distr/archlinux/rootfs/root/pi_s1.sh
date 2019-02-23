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

echo 'Configuring pacman.conf...'
case $arch in
  x86_64) mv /root/pacman-x86_64.conf /etc/pacman.conf
  rm -rf /root/pacman.conf
  ;;
  *) mv /root/pacman.conf /etc/pacman.conf
  rm -rf /root/pacman-x86_64.conf
  ;;
esac

echo "Updating and downloading addational packages..."
pacman-key --init
pacman-key --populate
pacman -Suy --noconfirm
[[ ! -z $postinstall ]] && pacman -Sw --noconfirm $postinstall
[[ $networkmanager == 1 ]] && pacman -Sw --noconfirm networkmanager

echo "FONT=ter-v16n" >> /etc/vconsole.conf

if [[ $graph == 1 ]]; then
  echo 'Downloading graphics packages...'
  pacman -Sw --noconfirm xorg xorg-drivers lightdm-gtk-greeter-settings xfce4 xfce4-goodies ttf-droid pulseaudio pavucontrol
  [[ $networkmanager == 1 ]] && pacman -Sw --noconfirm network-manager-applet
fi

if [[ $grub2 == 1 ]]; then
  pacman -S --noconfirm grub
  if [[ $flash_disk == 0 ]]; then
    pacman -S --noconfirm os-prober
  else
    pacman -Sw --noconfirm os-prober
  fi
fi

rm -rf /root/pi_s1.sh
