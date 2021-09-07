#Make debian minimal rootfs.

add_var "declare -gx" "dir" "${default_dir:-/mnt/mnt}"
add_var "declare -gx" "distr" "debian"
add_var "declare -gx" "LANG_SYSTEM" "en_US.UTF-8"
add_var "declare -gx" "hostname" "$distr"
add_var "declare -gx" "user_name" "$user_name"
add_var "declare -gx" "user_shell" "$user_shell"
add_var "declare -gx" "passwd" "$passwd_default"
add_var "declare -gx" "bootloader" "0"
add_var "declare -gx" "kernel" "0"
add_var "declare -gx" "add_soft" "0"
add_var "declare -gx" "copy_setup_script" "0"
add_var "declare -gx" "arch" "amd64"
add_var "declare -gx" "version_debian" "bullseye"
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
add_var "declare -gx" "debian_repos[main]" "deb $debian_mirror $version_debian main non-free contrib"
add_var "declare -gx" "debian_repos_order[0]" "main"
add_var "declare -gx" "debian_repos[updates]" "deb $debian_mirror $version_debian-updates main non-free contrib"
add_var "declare -gx" "debian_repos_order[1]" "updates"
add_var "declare -gx" "debian_repos[backports]" "deb $debian_mirror $version_debian-backports main non-free contrib"
add_var "declare -gx" "debian_repos_order[2]" "backports"
if [[ $version_debian == "bullseye" || $version_debian == "testing" ]]; then
    add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $version_debian-security main non-free contrib"
else
    add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $version_debian/updates main non-free contrib"
fi
add_var "declare -gx" "debian_repos_order[3]" "security"
add_var "declare -gx" "repos" "0"
add_var "declare -gx" "debian_add_i386" "1"
add_var "declare -gx" "preinstall" "locales"
add_var "declare -gx" "postinstall" ""
