#Install alpine minimal system.

if ! check_online; then
    msg_print warning "$M_HOST_OFFLINE"
    for interface in $(list_files "/sys/class/net/" -type l | sed '/lo/d'); do
        interface_setup_dhcp "$interface"
    done
fi
partition_auto "$BOOTLOADER_TYPE_DEFAULT" sda
format_and_mount "$BOOTLOADER_TYPE_DEFAULT" "/dev/$PART_ROOT" "/dev/$PART_BOOT"
function profile_end_action() {
    umount_partitions
    do_end_action 0
}

add_var "declare -gx" "dir" "${default_dir:-/mnt/mnt}"
add_var "declare -gx" "distr" "alpine"
add_var "declare -gx" "hostname" "$distr"
add_var "declare -gx" "user_name" "$user_name"
add_var "declare -gx" "user_shell" "$user_shell"
add_var "declare -gx" "passwd" "$passwd_default"
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
add_var "declare -gx" "preinstall" ""
add_var "declare -gx" "postinstall" "e2fsprogs"
add_var "declare -gx" "LANG" "en_US.UTF-8"

add_var "declare -gx" "fstab" "1"
add_var "declare -gx" "bootloader" "1"
add_var "declare -gx" "bootloader_type" "$BOOTLOADER_TYPE_DEFAULT"
add_var "declare -gx" "bootloader_name" "grub2"
[[ $BOOTLOADER_TYPE_DEFAULT != "bios" ]] || add_var "declare -gx" "bootloader_bios_place" "$bootloader_bios_place"
