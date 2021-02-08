print_param note "Distro-specific options:"
parse_arch $(uname -m)
print_param note "Arch avaliablex86_64,i686,aarch64,armv7h,etc."
read_param "" "Enter arch for installation" "$void_arch" arch text

read_param "" "Enter mirror" "$mirror_voidlinux" mirror_voidlinux text_empty

read_param "" "Do you want to install kernel? (Install system tools)" '' kernel yes_or_no
read_param "" "Do you want to install NetworkManager?" '' networkmanager yes_or_no

read_param "" "Enter version for installation (musl or glibc)" "$version_void" version_void text
[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "" "Do you want to add multilib (i386) repo?" '' void_add_i386 yes_or_no
read_param "" "Enter packages for preinstallation" "wget terminus-font" preinstall text_empty
read_param "" "Enter additional packages for postinstallation" "screen htop rsync bash-completion" postinstall text