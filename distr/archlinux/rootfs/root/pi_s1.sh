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

echo "Setting up locales..."
if [[ "$LANG" == "" ]]; then
  sed "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen >> /etc/locale.gen.new
else
  sed "s/#en_US.UTF-8/en_US.UTF-8/;s/#$LANG/$LANG/" /etc/locale.gen >> /etc/locale.gen.new
  echo "LANG=$LANG" >> /etc/locale.conf
fi
mv /etc/locale.gen{.new,}
locale-gen

echo 'Configuring pacman.conf...'
case $arch in
  x86_64) mv /root/pacman-x86_64.conf /etc/pacman.conf
  rm -rf /root/pacman.conf
  ;;
  *) mv /root/pacman.conf /etc/pacman.conf
  rm -rf /root/pacman-x86_64.conf
  ;;
esac

echo "Updating and installing addational packages..."
pacman -Suy --noconfirm
[[ ! -z $postinstall ]] && pacman -S --noconfirm --needed $postinstall
if [[ $networkmanager == 1 ]]; then
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager
fi

echo "FONT=ter-v16n" >> /etc/vconsole.conf

if [[ $graph == 1 ]]; then
  echo 'Installing graphics packages...'
  pacman -S --noconfirm xorg xorg-drivers lightdm-gtk-greeter-settings xfce4 xfce4-goodies ttf-droid pulseaudio pavucontrol
  [[ $networkmanager == 1 ]] && pacman -S --noconfirm network-manager-applet
  if [[ $lightdm_autostart == 1 ]]; then
    systemctl enable lightdm
  fi
fi

if [[ $grub2 == 1 ]]; then
  pacman -S --noconfirm grub
  if [[ $flash_disk == 0 ]]; then
    pacman -S --noconfirm os-prober
  else
    pacman -Sw --noconfirm os-prober
  fi
fi

rm -rf /root/{pi_s1.sh,configuration}
