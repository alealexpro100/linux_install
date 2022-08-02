#!/bin/bash

if [[ $LIVE_MODE == "0" ]]; then
  read_param "" "$M_ARCH_ENTER" "$alpine_arch" arch menu_var "$(gen_menu < <(echo -e "x86_64\nx86\naarch64\nmips64\nppc64le\ns390x"))"
else
  add_var "declare -gx" arch "$alpine_arch"
fi

if [[ $kernel == "1" ]]; then
  read_param "" "$M_KERNEL_TYPE" "$([[ $(detect_vm) || "$kernel_type" == "virtual" ]] && echo 1 || echo 0)" kernel_type menu_var "$(gen_menu < <(echo -e "vanilla\nvirtual"))"
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

read_param "" "$M_MIRROR" "$mirror_alpine" mirror_alpine text_empty


read_param "" "$M_DISTR_VER" 'v3.16' version_alpine text
add_var "declare -gx" "preinstall" ""
read_param "" "$M_PACK" "screen htop rsync bash-completion" postinstall text_empty