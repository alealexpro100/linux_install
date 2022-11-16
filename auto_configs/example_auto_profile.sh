#!/bin/bash

# Install alpine minimal system on real or virtual machine.
# This profile is fully automatic, meaning no user input is requested.

# First of all, let's check your connection
# We don't check for internet connection, but for connected state
if ! check_online; then
    # Should be printed while ISO auto mode
    msg_print warning "$M_HOST_OFFLINE"
    # We will use dhcp as simpliest way to setup connection
    # After dhcp setted up, we go further, not touching other interfaces
    for interface in $(list_files "/sys/class/net/" -type l | sed '/lo/d'); do
        interface_setup_dhcp "$interface" && break
    done
fi

# WIP: improve empty disk detection
# For now it just installs on first found disk, not even nvme
if [[ -e /dev/sda ]]; then
    PART_ROOT=sda
elif [[ -e /dev/vda ]]; then
    PART_ROOT=vda
fi

# Automatic partition
# PART_ROOT is already defined and PART_BOOT is defined by partition_auto
partition_auto auto "$BOOTLOADER_TYPE_DEFAULT" "$PART_ROOT"
format_and_mount "$BOOTLOADER_TYPE_DEFAULT" "/dev/$PART_ROOT" "/dev/$PART_BOOT"

# We re-define end function with necessary functionality
function profile_end_action() {
    umount_partitions
    do_end_action 0
}

# Now actual profile starts
# Here we just define needed options

# By default, directory to install is /mnt/mnt, but it can be easily re-defined
add_var "declare -gx" "dir" "${default_dir:-/mnt/mnt}"
add_var "declare -gx" "distr" "alpine"
add_var "declare -gx" "hostname" "$distr"
add_var "declare -gx" "user_name" "$user_name"
add_var "declare -gx" "user_shell" "$user_shell"
add_var "declare -gx" "passwd" "$passwd_default"

# This options unlocks installation for other additional software
# Without it, even if options checked, no additional software will be installed
add_var "declare -gx" "add_soft" "1"
add_var "declare -gx" "networkmanager" "0"
add_var "declare -gx" "ssh" "1"
add_var "declare -gx" "pipewire" "0"
add_var "declare -gx" "bluetooth" "0"
add_var "declare -gx" "printers" "0"
add_var "declare -gx" "arch" "x86_64"
add_var "declare -gx" "mirror_alpine" "$mirror_alpine"
add_var "declare -gx" "kernel" "1"
add_var "declare -gx" "kernel_type" "vanilla"
add_var "declare -gx" "version_alpine" "v3.14"
# Defined here packages will be installed with bootstrap action
add_var "declare -gx" "preinstall" ""
# Defined here packages will be installed after full install of system, but before custom_actions
add_var "declare -gx" "postinstall" "e2fsprogs"
# Useless for Alpine, but used in other distros. Used for setting locale of installing system
add_var "declare -gx" "LANG" "en_US.UTF-8"

# "Disk" options
# fstab generation is necessary to correctly mount root and, if avaliable, boot partitions
add_var "declare -gx" "fstab" "1"
add_var "declare -gx" "bootloader" "1"
# UEFI and BIOS types bootloaders are different.
# We should define it manually (even if auto-detected before)
add_var "declare -gx" "bootloader_type" "$BOOTLOADER_TYPE_DEFAULT"
# For now, only GRUB2 is supported and used in production
add_var "declare -gx" "bootloader_name" "grub2"
# This option is needed for UEFI. Variable $bootloader_bios_place defines /boot/efi place (usually it is the same).
[[ $BOOTLOADER_TYPE_DEFAULT != "bios" ]] || add_var "declare -gx" "bootloader_bios_place" "$bootloader_bios_place"
