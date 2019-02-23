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

echo "Please uncomment locales for locale-gen in nano."
sleep 3
nano /etc/locale.gen
locale-gen

while [[ $language == '' ]]; do
  echo "Enter language for your system."
  echo "Example (en_US.UTF-8/$LANG)"
  read -e -p "LANG="  -i "$LANG" language
done
echo "LANG=$language" >> /etc/locale.conf

echo "Installing addational packages..."
[[ ! -z $postinstall ]] && pacman -S --noconfirm $postinstall
if [[ $networkmanager == 1 ]]; then
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager
fi

if [[ $graph == 1 ]]; then
  echo 'Installing graphics packages...'
  pacman -S --noconfirm xorg xorg-drivers lightdm-gtk-greeter-settings xfce4 xfce4-goodies ttf-droid pulseaudio pavucontrol
  [[ $networkmanager == 1 ]] && pacman -S --noconfirm network-manager-applet
  if [[ $lightdm_autostart == 1 ]]; then
    systemctl enable lightdm
  fi
fi

rm -rf /root/configuration /root/pi_s2.sh
