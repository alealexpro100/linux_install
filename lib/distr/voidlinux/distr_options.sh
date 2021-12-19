#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
fi

read_param "" "$M_ARCH_ENTER" "$void_arch" arch menu_var "$(gen_menu < <(echo -e "x86_64\ni686\naarch64\narmv6l\narmv7l"))"

read_param "" "$M_MIRROR" "$mirror_voidlinux" mirror_voidlinux text_empty

read_param "" "$M_DISTR_VER" "$version_void" version_void menu_var "$(gen_menu < <(echo -e "glibc\nmusl"))"

[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' void_add_i386 yes_or_no
add_var "declare -gx" "preinstall" ""
read_param "" "$M_PACK" "screen htop rsync bash-completion" postinstall text_empty