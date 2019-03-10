#!/bin/bash
###############################################################
### linux_install script
###
### Copyright (C) 2018 Alexey Nasibulin
###
### By: Alexey Nasibulin (ktifhfl)
###
### License: GPL v3.0
###############################################################

case "$(uname -m)" in
  i[3-6]86|x86) arch_default="i686" ;;
  x86_64|amd64) arch_default="x86_64" ;;
  arm64|aarch64|armv8l) arch_default="aarch64" ;;
  *) arch_default="$(uname -m)";;
esac
echo "Arch avaliable: x86_64,i686,aarch64,armv7h,etc."
read_param "Enter arch for installation: " "$arch_default" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ $arch == "aarch64" || $arch == "arm" || $arch == "armv6h" || $arch == "armv7h" ]] && mirror_archlinux=$mirror_archlinux_arm

read_param "Enter mirror: " "$mirror_archlinux" mirror_archlinux text_empty

read_param "Enter packages for preinstallation: " "wget terminus-font" preinstall text_empty
read_param "Enter addational packages for postinstallation: " "base-devel screen htop rsync bash-completion" postinstall text_empty
read_param "Do you want to install NetworkManager? (Y/n): " '' networkmanager yes_or_no

# End of asking.

read_param "You're about to start installing $distr to $dir. Do you really want to continue? (Y/n): " "" enter yes_or_no
[[ $enter == 0 ]] && exit 0

source ./distr/$distr/${distr}_install.sh

echo "You'll need to run pi_s2.sh on working system."
echo ''
echo "Archlinux was installed to $dir."
