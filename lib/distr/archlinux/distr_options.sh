msg_print note "Distro-specific options:"
parse_arch $(uname -m)
msg_print note "Avaliable architectures: x86_64,i686,aarch64,armv7h,etc."
read_param "Enter arch for installation: " "$arch_arch" arch text

[[ $arch == "i686" ]] && mirror_archlinux=$mirror_archlinux_32
[[ "$arch" == "aarch64" || "$arch" == "arm*" ]] && mirror_archlinux=$mirror_archlinux_arm
read_param "Enter mirror: " "$mirror_archlinux" mirror_archlinux text_empty

read_param "Do you want to install kernel? (Y/n): " '' kernel yes_or_no
read_param "Do you want to install and enable NetworkManager? (Y/n): " '' networkmanager yes_or_no

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

read_param "Enter packages for preinstallation: " "wget nano" preinstall text_empty
read_param "Enter addational packages for postinstallation: " "base-devel screen htop rsync bash-completion" postinstall text_empty
[[ $arch == "x86_64" ]] && read_param "Do you want to enable multilib repo? (Y/n): " '' multilib yes_or_no