#!/bin/bash

if [[ $LIVE_MODE == "0" ]]; then
  read_param "" "$M_ARCH_ENTER" "$arch_arch" arch menu_var "$(gen_menu < <(echo -e "x86_64\ni686\naarch64\narm\narmv6h\narmv7h"))"
else
  add_var "declare -gx" arch "$arch_arch"
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
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE" "xorg" graphics_type menu_var "$(gen_menu < <(echo -e "xorg\nwayland"))"
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE" "DE" desktop_type menu_var "$(gen_menu < <(echo -e "DE\nM"))"
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "$(gen_menu < <(echo -e "plasma\nxfce4\ncinnanmon\ngnome"))"
      else
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "$(gen_menu < <(echo -e "plasma\ngnome"))"
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "plasma-desktop" desktop_packages text_empty
    fi
    read_param "" "$M_DM_E" '' dm_install yes_or_no
    if [[ $dm_install == "1" ]]; then
      read_param "" "$M_DM" "sddm" desktop_dm menu_var "$(gen_menu < <(echo -e "gdm\nlightdm\nsddm"))"
    fi
  fi
fi

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "" "$M_MIRROR" "$mirror_archlinux" mirror_archlinux text_empty


[[ $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' arch_add_i386 yes_or_no
add_var "declare -gx" "preinstall" ""
read_param "" "$M_PACK" "nano screen htop rsync bash-completion" postinstall text_empty