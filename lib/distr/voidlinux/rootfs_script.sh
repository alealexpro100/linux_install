#!/bin/bash

user_groups="audio,video,input,network,storage,wheel"
base_setup glibc
[[ $version_void == "glibc" ]] && locale_setup_voidlinux /etc/locale.conf

#XBPS setup.
msg_print note "XBPS setup..."
xbps_install="xbps-install -y"

msg_print note 'Configuring xbps.d...'
cp /usr/share/xbps.d/*-*-*.conf /etc/xbps.d/
for file in /etc/xbps.d/*; do
  [[ -e "$file" ]] || break
  sed -ie "s|https://[a-zA-Z0-9./-]\+$|$mirror_voidlinux|" "$file"
done
rm -rf /etc/xbps.d/install_repo.conf
xbps-install -S

msg_print note "XBPS is ready."

#Void setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

#Network setup.
if [[ $networkmanager != "1" ]]; then
  msg_print note "Using default network config."
  to_enable="$to_enable dhcpcd"
  to_install="$to_install dhcpcd"
fi

if [[ $kernel == "1" ]]; then
  to_install="$to_install linux base-system"
fi

if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install NetworkManager"
    to_enable="$to_enable NetworkManager"
  fi
  if [[ $ssh == "1" ]]; then
    to_install="$to_install openssh"
    to_enable="$to_enable sshd"
  fi
  if [[ $pipewire == "1" ]]; then
    to_install="$to_install pipewire alsa-pipewire"
  fi
fi

[[ -n $to_install ]] && $xbps_install $to_install
for service in $to_enable; do
    if [[ -d "/etc/sv/$service" ]]; then
      msg_print note "Enabling service $service."
      ln -s "/etc/sv/$service" /etc/runit/runsvdir/default/
    else
      msg_print warning "Service $service not found!"
    fi
done

msg_print note "Packages installed."

case "$bootloader_name" in
  grub2)
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install grub-x86_64-efi grub-i386-efi"
    $xbps_install $to_install
    [[ $removable_disk == "0" ]] && msg_print warning "Os-prober can't be removed."
    grub_config
  ;;
  *) msg_print note "Bootloader not chosen."
esac

# Keep more space free
msg_print note "Cleaning up..."
rm -rf /var/cache/xbps/*
