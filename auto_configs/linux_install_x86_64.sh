#Make alpine minimal rootfs.

add_var "declare -gx" "dir" "${default_dir:-/mnt/mnt}"
add_var "declare -gx" "distr" "alpine"
add_var "declare -gx" "LANG_SYSTEM" "en_US.UTF-8"
add_var "declare -gx" "hostname" "$distr"
add_var "declare -gx" "user_name" "user"
add_var "declare -gx" "user_shell" "/bin/bash"
add_var "declare -gx" "passwd" "pass"
add_var "declare -gx" "bootloader" "0"
add_var "declare -gx" "kernel" "0"
add_var "declare -gx" "add_soft" "0"
add_var "declare -gx" "arch" "x86_64"
add_var "declare -gx" "mirror_alpine" "$mirror_alpine"
add_var "declare -gx" "version_alpine" "v3.15"
add_var "declare -gx" "preinstall" ""
add_var "declare -gx" "postinstall" ""
