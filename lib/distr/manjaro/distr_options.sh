#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

read_param "" "$M_ARCH_ENTER" "$arch_arch" arch menu_var "$(gen_menu < <(echo -e "x86_64\naarch64"))"

[[ "$arch" == "aarch64" ]] && mirror_archlinux=$mirror_manjaro_arm
read_param "" "$M_MIRROR" "$mirror_manjaro" mirror_archlinux text_empty

add_var "declare -gx" "preinstall" ""
read_param "" "$M_PACK" "nano base-devel screen htop rsync bash-completion" postinstall text_empty