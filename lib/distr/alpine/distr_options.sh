
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
fi

read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc.\n" "$M_ARCH_ENTER" "$alpine_arch" arch text

read_param "" "$M_MIRROR" "$mirror_alpine" mirror_alpine text_empty

read_param "" "$M_KERNEL" '' kernel yes_or_no

read_param "" "$M_DISTR_VER" 'edge' version_alpine text
read_param "" "$M_PACK_PRE" "wget terminus-font" preinstall text_empty
read_param "" "$M_PACK_POST" "screen htop rsync bash-completion" postinstall text_empty