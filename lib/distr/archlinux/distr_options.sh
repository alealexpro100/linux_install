msg_print note "Distro-specific options:"
parse_arch $(uname -m)
msg_print note "Avaliable architectures: x86_64,i686,aarch64,armv7h,etc."
read_param "Enter arch for installation: " "$arch_arch" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "Enter mirror: " "$mirror_archlinux" mirror_archlinux text_empty

read_param "Do you want to install kernel? (Y/n): " '' kernel yes_or_no
read_param "Do you want to install and enable NetworkManager? (Y/n): " '' networkmanager yes_or_no
read_param "Do you want to install and enable pulseaudio? (Y/n): " '' pulseaudio yes_or_no
read_param "Do you want to install and enable bluetooth? (Y/n): " '' bluetooth yes_or_no
read_param "Do you want to add printers support? (Y/n): " '' printers yes_or_no

if [[ $bootloader == "1" ]]; then
  msg_print note "Choose grub2. Others are not supported yet."
  if [[ $bootloader_type = uefi ]]; then
    msg_print note "Avaliable bootloaders: grub2, syslinux, systemd, refind."
    read_param "Enter name of bootloader: " "grub2" bootloader_name text
  else
    msg_print note "Avaliable bootloaders: grub2, syslinux."
    read_param "Enter name of bootloader: " "grub2" bootloader_name text
  fi
fi

if [[ $graphics == "1" ]]; then
  msg_print note "Wayland is not supported now. Do NOT choose it."
  while ! [[ $graphics_type == "xorg" || $graphics_type == "wayland" ]]; do
    read_param "Enter type of graphics (xorg/wayland): " "xorg" graphics_type text
  done
  msg_print note "DE - Desktop environment, WM - window manager, M - manual."
  while ! [[ $desktop_type == "DE" || $desktop_type == "WM" || $desktop_type == "M" ]]; do
    read_param "Enter desktop type (DE/WM/M): " "DE" desktop_type text
  done
  if [[ $desktop_type != "M" ]]; then
    if [[ $graphics_type == "xorg" ]]; then
      if [[ $desktop_type == "DE" ]]; then
        msg_print note "Avaliable DEs: plasma, xfce4, cinnamon, gnome."
        read_param "Enter DE name: " "xfce4" desktop_de text
      else
        msg_print note "Avaliable WMs: icewm."
        read_param "Do you want to install addational software: " "icewm" desktop_wm text
      fi
    else
      return_err "Wayland is not supported now!"
    fi
    msg_print note "Addational software."
    read_param "Do you want to install firefox? (Y/n): " '' firefox_soft yes_or_no
    read_param "Do you want to install chromium? (Y/n): " '' chromium_soft yes_or_no
    read_param "Do you want to install office software? (Y/n): " '' office_soft yes_or_no
    read_param "Do you want to install administration software? (Y/n): " '' admin_soft yes_or_no
  else
    read_param "Enter desktop package(s) or nothing: " "xfce4 xfce4-goodies" desktop_packages text_empty
  fi
  if [[ $dm_install == "1" ]]; then
    msg_print note "DM - Display Manager."
    msg_print note "Avaliable DEs: gdm, lightdm, sddm."
    read_param "Enter DM name: " "lightdm" desktop_dm text
  fi
fi

read_param "Enter packages for preinstallation: " "wget nano" preinstall text_empty
read_param "Enter addational packages for postinstallation: " "base-devel screen htop rsync bash-completion" postinstall text_empty
[[ $arch == "x86_64" ]] && read_param "Do you want to enable multilib repo? (Y/n): " '' multilib yes_or_no