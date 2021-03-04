#Make archlinux minimal rootfs.

add_var "declare -gx" dir "${default_dir:-/mnt/mnt}"
add_var "declare -gx" distr "archlinux"
add_var "declare -gx" hostname "archlinux"
add_var "declare -gx" user_name "user"
add_var "declare -gx" user_shell "/bin/bash"
add_var "declare -gx" passwd "pass"
add_var "declare -gx" copy_setup_script "1"
add_var "declare -gx" arch "x86_64"
add_var "declare -gx" mirror_archlinux "$mirror_archlinux"
add_var "declare -gx" kernel "0"
add_var "declare -gx" networkmanager "0"
add_var "declare -gx" multilib "0"
add_var "declare -gx" preinstall ""
add_var "declare -gx" postinstall ""
add_var "declare -gx" LANG "en_US.UTF-8"
