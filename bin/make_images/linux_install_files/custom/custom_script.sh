#!/bin/bash
#Apk setup
sed -i "s/#//g" /etc/apk/repositories
apk update

#Network setup.
echo -e "auto lo\n  iface lo inet loopback\n" > /etc/network/interfaces

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

#Mini web-server or nginx
#apk add mini_httpd
#rc-update add mini_httpd boot
apk add nginx
rc-update add nginx boot

#Setup xorg server
apk add --no-scripts eudev
#apk add xorg-server xf86-input-libinput
rc-update del mdev sysinit
rc-update del hwdrivers sysinit
rc-update add udev-trigger sysinit
rc-update add udev sysinit
rc-update add udev-postmount default
#apk add icewm rxvt-unicode
#cp -R /usr/share/icewm/. /root/.icewm
#echo -e "#/bin/sh\nicewm-session"  >> /root/.xinitrc
#chmod +x /root/.xinitrc

#Some other.
echo "root:pass" | chpasswd -c SHA512
echo alpine_pxe > /etc/hostname
sed -i "/You may change/d" /etc/motd
echo -e "SSH is working on port 22.\nPassword for root is pass.\n" >> /etc/motd
sed -i "8s/tty1/#tty1/" /etc/inittab
echo -e "\ntty1::respawn:/bin/login -f root" >> /etc/inittab
sed -i "1s/ash/bash/" /etc/passwd
