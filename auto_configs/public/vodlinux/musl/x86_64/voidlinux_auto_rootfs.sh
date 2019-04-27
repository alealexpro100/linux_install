#!/bin/bash

add_var distr voidlinux
add_var dir /mnt/mnt
add_var hostname voidlinux
add_var user_name alexey
add_var passwd pass
add_var fstab 0
add_var grub2 0
add_var grub2_type ''
add_var arch x86_64
add_var version_void musl
add_var kernel 0
add_var mirror_voidlinux 'https://alpha.de.repo.voidlinux.org/current'
add_var preinstall 'wget terminus-font screen htop rsync bash-completion'
add_var networkmanager 0
