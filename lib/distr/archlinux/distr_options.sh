
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE (xorg/wayland)" "xorg" graphics_type text_check xorg,wayland
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE (DE/WM/M)" "DE" desktop_type text_check DE,WM,M
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        if [[ $desktop_type == "DE" ]]; then
          read_param "$M_DESKTOP_DE_M: plasma, xfce4, cinnamon, gnome.\n" "$M_DESKTOP_DE" "plasma" desktop_de text_check plasma,xfce4,cinnanmon,gnome
        else
          read_param "$M_DESKTOP_WM_M: icewm.\n" "$M_DESKTOP_WM" "icewm" desktop_wm text_check icewm
        fi
      else
        return_err "Wayland is not supported now!"
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "plasma-desktop" desktop_packages text_empty
    fi
    read_param "" "$M_DM_E" '' dm_install yes_or_no
    if [[ $dm_install == "1" ]]; then
      read_param "$M_DM_M: gdm, lightdm, sddm.\n" "$M_DM" "sddm" desktop_dm text_check gdm,lightdm,sddm
    fi
  fi
fi

read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc.\n" "$M_ARCH_ENTER" "$arch_arch" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "" "$M_MIRROR" "$mirror_archlinux" mirror_archlinux text_empty

read_param "" "$M_KERNEL" '' kernel yes_or_no

[[ $arch == "x86_64" ]] && read_param "" "$M_MULTILIB" '' arch_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "wget nano" preinstall text_empty
read_param "" "$M_PACK_POST" "base-devel screen htop rsync bash-completion" postinstall text_empty