#Install alpine minimal system.

mkfs.ext4 -F /dev/sda1
mount -t ext4 /dev/sda1 /mnt/mnt

sleep 2s

add_var "declare -gx" "dir" "${default_dir:-/mnt/mnt}"
add_var "declare -gx" "distr" "alpine"
add_var "declare -gx" "hostname" "$distr"
add_var "declare -gx" "user_name" "user"
add_var "declare -gx" "user_shell" "/bin/bash"
add_var "declare -gx" "passwd" "pass"
add_var "declare -gx" "copy_setup_script" "0"
add_var "declare -gx" "add_soft" "0"
add_var "declare -gx" "networkmanager" "0"
add_var "declare -gx" "pulseaudio" "0"
add_var "declare -gx" "bluetooth" "0"
add_var "declare -gx" "printers" "0"
add_var "declare -gx" "arch" "x86_64"
add_var "declare -gx" "mirror_alpine" "$mirror_alpine"
add_var "declare -gx" "kernel" "1"
add_var "declare -gx" "version_alpine" "v3.14"
add_var "declare -gx" "preinstall" ""
add_var "declare -gx" "postinstall" ""
add_var "declare -gx" "LANG" "en_US.UTF-8"

add_var "declare -gx" "fstab" "1"
add_var "declare -gx" "bootloader" "1"
add_var "declare -gx" "bootloader_type" "bios"
add_var "declare -gx" "bootloader_name" "grub2"
add_var "declare -gx" "bootloader_bios_place" "/dev/sda"
