#!/bin/bash

add_var distr archlinux
add_var dir /mnt/mnt
add_var hostname archlinux
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
add_var arch i686
add_var mirror_archlinux 'http://mirror.archlinux32.org'
add_var preinstall 'wget terminus-font'
add_var postinstall 'base-devel screen htop rsync bash-completion'
add_var networkmanager 1
