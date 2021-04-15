#!/bin/bash
#Apk setup
sed -i "s/#//g" /etc/apk/repositories
apk update

#Network setup.
sed -i 's/#auto/auto/;s/#  /  /g' /etc/network/interfaces

#Extended fonts for console
apk add terminus-font
rc-update add consolefont boot
sed -i "6s/default8x16.psf.gz/ter-v16n.psf.gz/" /etc/conf.d/consolefont
sed -i "92s/NO/YES/;92s/#//" /etc/rc.conf

#For linux_install
apk add bash zstd perl dpkg findmnt lsblk dialog

#Disk change tools
apk add cfdisk e2fsprogs

#Addational soft
apk add htop rsync

#SSH
apk add dropbear
rc-update add dropbear boot

#Some other.
echo "root:pass" | chpasswd -c SHA512
echo alpine_pxe > /etc/hostname
sed -i "/You may change/d" /etc/motd
echo -e "Please, ignore errors. It is normal.\nSSH is working on port 22.\nPassword for root is pass.\n" >> /etc/motd
sed -i "8s/tty1/#tty1/" /etc/inittab
echo -e "\ntty1::respawn:/bin/login -f root" >> /etc/inittab
sed -i "1s/ash/bash/" /etc/passwd

#Bash profile fix for busybox.
sed -i "s/dircolors/#dircolors/" /root/.bashrc
