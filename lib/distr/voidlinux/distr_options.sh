read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc.\n" "$M_ARCH_ENTER" "$void_arch" arch text

read_param "" "$M_MIRROR" "$mirror_voidlinux" mirror_voidlinux text_empty

while ! [[ $version_void == "musl" || $version_void == "glibc" ]]; do
  read_param "" "$M_DISTR_VER (musl/glibc)" "$version_void" version_void text
done

read_param "" "$M_KERNEL" '' kernel yes_or_no
read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no

[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' void_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "wget terminus-font" preinstall text_empty
read_param "" "$M_PACK_POST" "screen htop rsync bash-completion" postinstall text_empty