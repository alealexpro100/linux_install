msg_print note "Distro-specific options:"
parse_arch $(uname -m)
msg_print note "Arch avaliable: x86_64,i686,aarch64,armv7h,etc."
read_param "Enter arch for installation: " "$void_arch" arch text

read_param "Enter mirror: " "$mirror_voidlinux" mirror_voidlinux text_empty

read_param "Enter version for installation (musl or glibc): " "$version_void" version_void text
[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "Do you want to add multilib (i386) repo? (Y/n): " '' void_add_i386 yes_or_no
read_param "Enter packages for preinstallation: " "wget terminus-font screen htop rsync bash-completion" preinstall text_empty
read_param "Do you want to install NetworkManager? (Y/n): " '' networkmanager yes_or_no
read_param "Do you want to install kernel? (Install system tools) (Y/n): " '' kernel yes_or_no
