#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
fi

# shellcheck disable=SC2046
read_param "" "$M_ARCH_ENTER" "$void_arch" arch menu_var $(echo -e "x86_64\ni686\naarch64\narmv6l\narmv7l" | gen_menu)

read_param "" "$M_MIRROR" "$mirror_voidlinux" mirror_voidlinux text_empty

while ! [[ $version_void == "musl" || $version_void == "glibc" ]]; do
  read_param "" "$M_DISTR_VER (musl/glibc)" "$version_void" version_void text
done

[[ $version_void == "glibc" && $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' void_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "wget terminus-font" preinstall text_empty
read_param "" "$M_PACK_POST" "screen htop rsync bash-completion" postinstall text_empty