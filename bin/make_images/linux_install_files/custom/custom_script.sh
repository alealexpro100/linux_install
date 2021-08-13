#!/bin/bash

#Enable apk repositories
sed -i "s/#//g" /etc/apk/repositories
apk update

#Extended fonts for console
rc-update add consolefont boot
sed -i "6s/default8x16.psf.gz/ter-v16n.psf.gz/" /etc/conf.d/consolefont
sed -i "92s/NO/YES/;92s/#//" /etc/rc.conf

#Dependencies
apk add terminus-font bash dropbear zstd perl dpkg findmnt lsblk dialog cfdisk e2fsprogs wireless-tools wpa_supplicant htop rsync

#SSH
rc-update add firstboot default
rc-update add modloop sysinit
rc-update add dropbear boot
rc-update del networking boot

#Some other.
PASSWORD=pass
echo "root:$PASSWORD" | chpasswd -c SHA512
echo alpine_pxe > /etc/hostname
echo -e "\n### Welcome to linux_install! ###\nSSH is working on port 22.\nPassword for root is '$PASSWORD'.\n" > /etc/motd
sed -i "s|tty1.*|tty1::respawn:/bin/login -f root|" /etc/inittab
sed -i "1s/ash/bash/" /etc/passwd

#Bash remove error for busybox.
if [[ -f /root/.bashrc ]]; then
  sed -i "/dircolors/d" /root/.bashrc
fi