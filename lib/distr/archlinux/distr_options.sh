read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc.\n" "$M_ARCH_ENTER" "$arch_arch" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "" "$M_MIRROR" "$mirror_archlinux" mirror_archlinux text_empty

read_param "" "$M_KERNEL" '' kernel yes_or_no
read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no

[[ $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' multilib yes_or_no
read_param "" "$M_PACK_PRE" "wget nano" preinstall text_empty
read_param "" "$M_PACK_POST" "base-devel screen htop rsync bash-completion" postinstall text_empty