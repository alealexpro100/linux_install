#!/bin/bash

if [[ $kernel == "1" ]]; then
  if [[ $(detect_vm) || "$kernel_type" == "virtual" ]]; then
    gen_menu < <(echo -e "virtual\nvanilla")
  else
    gen_menu < <(echo -e "vanilla\nvirtual")
  fi
  read_param "" "$M_KERNEL_TYPE" '0' kernel_type menu_var "${tmp_gen_menu[@]}"
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi

gen_menu < <(echo -e "x86_64\nx86\naarch64\nmips64\nppc64le\ns390x")
read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc.\n" "$M_ARCH_ENTER" "$alpine_arch" arch menu_var "${tmp_gen_menu[@]}"

read_param "" "$M_MIRROR" "$mirror_alpine" mirror_alpine text_empty


read_param "" "$M_DISTR_VER" 'v3.15' version_alpine text
add_var "declare -gx" "preinstall" ""
read_param "" "$M_PACK" "screen htop rsync bash-completion" postinstall text_empty