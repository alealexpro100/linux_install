#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
fi

gen_menu < <(echo -e "x86_64\ni686\naarch64\narmv6l\narmv7l")
read_param "" "$M_ARCH_ENTER" "$void_arch" arch menu_var "${tmp_gen_menu[@]}"

read_param "" "$M_MIRROR" "$mirror_voidlinux" mirror_voidlinux text_empty

gen_menu < <(echo -e "glibc\nmusl")
read_param "" "$M_DISTR_VER" "$version_void" version_void menu_var "${tmp_gen_menu[@]}"

[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' void_add_i386 yes_or_no
add_var "declare -gx" "preinstall" "wget"
read_param "" "$M_PACK" "screen htop rsync bash-completion" postinstall text_empty