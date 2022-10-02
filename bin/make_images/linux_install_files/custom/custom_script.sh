#!/bin/bash

#Enable apk repositories
sed -i "s/#//g" /etc/apk/repositories
apk update

#Extended fonts for console
rc-update add consolefont boot
sed -i "6s/default8x16.psf.gz/ter-v16n.psf.gz/" /etc/conf.d/consolefont
sed -i "92s/NO/YES/;92s/#//" /etc/rc.conf

#Dependencies
apk add terminus-font bash dropbear zstd perl dpkg debootstrap findmnt \
  lsblk dialog cfdisk e2fsprogs dmidecode wireless-tools wpa_supplicant htop sfdisk

#Servcies
rc-update add firstboot default
rc-update add modloop sysinit
rc-update add dropbear boot

#Prevent network setup
echo > /etc/network/interfaces
rc-update del networking boot

#Some other.
echo -e "\n### Welcome to linux_install client! ###\nSSH is working on port 22.\nPassword for root is '$passwd'.\n" > /etc/motd
sed -i "s|tty1.*|tty1::respawn:/bin/login -f root|" /etc/inittab
sed -i "1s/ash/bash/" /etc/passwd
mkdir -p /mnt/mnt
ln -s /root/linux_install/auto_configs /auto_configs
rm -rf /var/cache/apk/*

#Bash remove error for busybox.
if [[ -f /root/.bashrc ]]; then
  sed -i "/dircolors/d" /root/.bashrc
fi
