#!/bin/bash

user_groups="audio,video,input,network,storage,wheel"
base_setup glibc
locale_setup /etc/locale.conf

#Pacman setup.
msg_print note "Pacman setup..."
pacman_install="pacman -Suy --needed --noconfirm"

mv /etc/pacman.d/mirrorlist{,.pacnew}
mv /etc/pacman.d/mirrorlist{.used,}

msg_print note "Pacman is ready."

#Arch setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

#Network setup.
if [[ $networkmanager != "1" ]]; then
  msg_print note "Using default network config."
  echo -e "[Match]\nName=enp1s0\n\n[Network]\nDHCP=yes" >> /etc/systemd/network/20-wired.network
  to_enable="$to_enable systemd-networkd"
fi

if [[ $kernel == "1" ]]; then
  to_install="$to_install linux linux-firmware linux-headers"
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install networkmanager crda"
    to_enable="$to_enable NetworkManager.service"
  fi
  if [[ $ssh == "1" ]]; then
    to_install="$to_install openssh"
    to_enable="$to_enable sshd"
  fi
fi

[[ -n "$to_install" ]] && $pacman_install $to_install
for service in $to_enable; do
  systemctl enable "$service"
done

msg_print note "Packages are installed."

case "$bootloader_name" in
  grub2)
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
  *) msg_print note "Bootloader not chosen."
esac