#Make voidlinux minimal rootfs.

add_var "declare -gx" dir "${default_dir:-/mnt/mnt}"
add_var "declare -gx" distr "voidlinux"
add_var "declare -gx" hostname "voidlinux"
add_var "declare -gx" user_name "user"
add_var "declare -gx" user_shell "/bin/bash"
add_var "declare -gx" passwd "pass"
add_var "declare -gx" copy_setup_script "0"
add_var "declare -gx" arch "x86_64"
add_var "declare -gx" mirror_voidlinux "$mirror_voidlinux"
add_var "declare -gx" kernel "0"
add_var "declare -gx" networkmanager "0"
add_var "declare -gx" void_add_i386 "1"
add_var "declare -gx" preinstall
add_var "declare -gx" postinstall
add_var "declare -gx" LANG "en_US.UTF-8"
