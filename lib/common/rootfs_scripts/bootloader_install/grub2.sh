
# Bootloader install.
msg_print note "Installing $bootloader_name..."

function grub_config() {
  if [[ $bootloader_type = uefi ]]; then
    grub-install --target=i386-efi --efi-directory=/boot --removable
    grub-install --target=x86_64-efi --efi-directory=/boot --removable
  else
    grub-install --target=i386-pc --debug --force $bootloader_bios_place
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}

case $distr in
  alpine)
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install grub-efi"
    [[ $bootloader_type = bios ]] && to_install="$to_install grub-pc"
    $apk_install $to_install
    [[ $removable_disk == "1" ]] && msg_print warning "Os-prober can't be installed."
    grub_config
  ;;
  archlinux) 
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install efibootmgr"
    $pacman_install $to_install
    if [[ $removable_disk == "1" ]]; then
      $pacman_install -w os-prober
    else
      $pacman_install os-prober
    fi
    grub_config
  ;;
  debian)
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install grub-efi"
    [[ $bootloader_type = bios ]] && to_install="$to_install grub-bios"
    $apt_install $to_install
    if [[ $removable_disk == "0" ]]; then
      apt -y remove os-prober;
    fi
    grub_config
  ;;
  voidlinux)
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install grub-x86_64-efi grub-i386-efi"
    $xbps_install $to_install
    [[ $removable_disk == "0" ]] && msg_print warning "Os-prober can't be removed."
    grub_config
  ;;
  *)
  msg_print error "$bootloader_name installation is not supported for $distro. Skipping."
  ;;
esac

msg_print note "Installed $bootloader_name."