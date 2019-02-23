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

echo 'Final steps...'
apt -y install console-setup-linux
dpkg-reconfigure tzdata locales


if [[ -z $postinstall ]]; then
  echo 'Installing addational packages...'
  apt -y install $postinstall
fi
if [[ $networkmanager == 1 ]]; then
  echo "Installing Network Manager..."
  apt -y install network-manager
  if [[ $debian_distr == stretch ]]; then
    echo "Fixing wi-fi network."
    mv /{root,etc/NetworkManager}/NetworkManager.conf
  else
    rm -rf /root/NetworkManager.conf
  fi
fi

if [[ $graph == '1' ]]; then
  echo 'Installing graphics packages...'
  apt -y install xserver-xorg-video-all xserver-xorg-input-all xserver-xorg
  apt -y install xfce4 xfce4-goodies xfwm4-themes
  apt -y install xfwm4-themes
  [[ $networkmanager == '1' ]] && apt -y install network-manager-gnome
  [[ $lightdm_autostart == 0 ]] && systemctl disable lightdm
  echo 'Fixing x-server...'
  echo -e "\n#Tempory fix\nneeds_root_rights=yes" >> /etc/X11/Xwrapper.config
fi

rm -rf /root/configuration /root/pi_s2.sh
