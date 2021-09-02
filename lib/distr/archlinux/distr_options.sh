#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PIPEWIRE" '' pipewire yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    # shellcheck disable=SC2046
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE" "xorg" graphics_type menu_var $(echo -e "xorg\nwayland" | gen_menu)
    # shellcheck disable=SC2046
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE" "DE" desktop_type menu_var $(echo -e "DE\nM" | gen_menu)
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        # shellcheck disable=SC2046
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var $(echo -e "plasma\nxfce4\ncinnanmon\ngnome" | gen_menu)
      else
        # shellcheck disable=SC2046
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var $(echo -e "plasma\ngnome" | gen_menu)
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "plasma-desktop" desktop_packages text_empty
    fi
    read_param "" "$M_DM_E" '' dm_install yes_or_no
    if [[ $dm_install == "1" ]]; then
      # shellcheck disable=SC2046
      read_param "" "$M_DM" "sddm" desktop_dm menu_var $(echo -e "gdm\nlightdm\nsddm" | gen_menu)
    fi
  fi
fi

# shellcheck disable=SC2046
read_param "" "$M_ARCH_ENTER" "$arch_arch" arch menu_var $(echo -e "x86_64\ni686\naarch64\narm\narmv6h\narmv7h" | gen_menu)

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "" "$M_MIRROR" "$mirror_archlinux" mirror_archlinux text_empty


[[ $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' arch_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "wget nano" preinstall text_empty
read_param "" "$M_PACK_POST" "base-devel screen htop rsync bash-completion" postinstall text_empty