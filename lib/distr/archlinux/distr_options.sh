read_param "$M_ARCH_AVAL x86_64,i686,aarch64,armv7h,etc." "$M_ARCH_ENTER" "$arch_arch" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "" "Enter mirror" "$mirror_archlinux" mirror_archlinux text_empty

read_param "" "Do you want to install kernel?" '' kernel yes_or_no
read_param "" "Do you want to install and enable NetworkManager?" '' networkmanager yes_or_no

if [[ $bootloader == "1" ]]; then
  print_param note "Choose grub2. Others are not supported yet."
  if [[ $bootloader_type = uefi ]]; then
    print_param note "Avaliable bootloadersgrub2, syslinux, systemd, refind."
    read_param "" "Enter name of bootloader" "grub2" bootloader_name text
  else
    print_param note "Avaliable bootloadersgrub2, syslinux."
    read_param "" "Enter name of bootloader" "grub2" bootloader_name text
  fi
fi

read_param "" "Enter packages for preinstallation" "wget nano" preinstall text_empty
read_param "" "Enter addational packages for postinstallation" "base-devel screen htop rsync bash-completion" postinstall text_empty
[[ $arch == "x86_64" ]] && read_param "" "Do you want to enable multilib repo?" '' multilib yes_or_no