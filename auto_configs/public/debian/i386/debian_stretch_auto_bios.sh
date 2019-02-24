#!/bin/bash

case $(uname -m) in
  x86_64|amd64) debian_arch_default=amd64
  ;;
  arm64|aarch64|armv8l) debian_arch_default=arm64
  ;;
  i[3-6]86|x86) debian_arch_default=i386
  ;;
  *) debian_arch_default=$(uname -m)
  ;;
esac

add_var distr debian
add_var dir /mnt/mnt
add_var hostname debian
add_var user_name alexey
add_var passwd pass
add_var fstab 1
add_var grub2 1
add_var grub2_type bios
add_var grub2_bios_place "$(findmnt -funcevo SOURCE $dir)"
add_var flash_disk 1
add_var graph 1
add_var lightdm_autostart 0
add_var setup_script 1
add_var debian_arch i386
add_var debian_distr stretch
add_var repo_debian_main 'deb http://deb.debian.org/debian $debian_distr main non-free contrib'
add_var repo_debian_updates 'deb http://deb.debian.org/debian $debian_distr-updates main non-free contrib'
add_var repo_debian_backports 'deb http://deb.debian.org/debian $debian_distr-backports main non-free contrib'
add_var repo_debian_security 'deb http://security.debian.org/ $debian_distr/updates main non-free contrib'
add_var repos 1
add_var repo_debian_wine 'deb http://dl.winehq.org/wine-builds/debian/ $debian_distr main'
add_var repo_debian_webmin 'deb [arch=$debian_arch] http:///download.webmin.com/download/repository sarge contrib'
add_var preinstall locales,sudo
add_var postinstall "usbutils pciutils dosfstools software-properties-common bash-completion"
add_var kernel_var 1
add_var backports_kernel 0
add_var networkmanager 1
