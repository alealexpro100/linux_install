read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc." "$M_ARCH_ENTER" "$alpine_arch" arch text

read_param "" "Enter mirror" "$mirror_alpine" mirror_alpine text_empty

read_param "" "Do you want to install kernel? (Install system tools)" '' kernel yes_or_no
read_param "" "Do you want to install NetworkManager?" '' networkmanager yes_or_no

read_param "" "Enter version of distro" 'edge' version_alpine text
read_param "" "Enter packages for preinstallation" "wget terminus-font" preinstall text_empty
read_param "" "Enter additional packages for postinstallation" "screen htop rsync bash-completion" postinstall text