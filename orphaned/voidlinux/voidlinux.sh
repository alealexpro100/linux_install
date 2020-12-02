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
  armhf|armlf) arch_default="arm" ;;
  *) arch_default="$(uname -m)";;
esac
echo "Arch avaliable: x86_64,i686,aarch64,armv7h,etc."
read_param "Enter arch for installation: " "$arch_default" arch text

read_param "Enter mirror: " "$mirror_voidlinux" mirror_voidlinux text_empty

read_param "Enter version for installation (musl or glibc): " "$version_void" version_void text
[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "Do you want to add multilib (i386) repo? (Y/n): " '' void_add_i386 yes_or_no
read_param "Enter packages for preinstallation: " "wget terminus-font screen htop rsync bash-completion" preinstall text_empty
read_param "Do you want to install NetworkManager? (Y/n): " '' networkmanager yes_or_no
read_param "Do you want to install kernel? (Install system tools) (Y/n): " '' kernel yes_or_no

# End of asking.

read_param "You're about to start installing $distr to $dir. Do you really want to continue? (Y/n): " "" enter yes_or_no
[[ $enter == 0 ]] && exit 0

source ./distr/$distr/${distr}_install.sh

echo ''
echo "Void linux was installed to $dir."