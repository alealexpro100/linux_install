#!/bin/bash

user_groups="audio video input wheel"
base_setup musl
msg_print note "Alpine has no support of locales. Skipping."

#Apk config
msg_print note "Apk setup..."
apk_install="apk add"

[[ -f /etc/apk/repositories ]] && rm -rf /etc/apk/repositories
echo -e "$mirror_alpine/$version_alpine/main\n$mirror_alpine/$version_alpine/community" >> /etc/apk/repositories
apk update

msg_print note "Apk is ready."

#Alpine setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

#Activate services for booting
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add hwdrivers sysinit
rc-update add mdev sysinit
rc-update add bootmisc boot
rc-update add hostname boot
rc-update add hwclock boot
rc-update add modules boot
#rc-update add swap boot
rc-update add sysctl boot
rc-update add syslog boot
rc-update add urandom boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

#Network setup.
echo -e "#auto eth0\n#\tiface eth0 inet dhcp\n#\t\thostname \$(hostname)\n" >> /etc/network/interfaces
if [[ $networkmanager != "1" ]]; then
  msg_print note "Using default network config."
  rc-update add networking boot
  sed -i "s/#//g" /etc/network/interfaces
fi

if [[ $kernel == "1" ]]; then
  case "$kernel_type" in
    vanilla) to_install="$to_install linux-firmware linux-lts";;
    virtual) to_install="$to_install linux-virt";;
    *) return_err "Incorrect paramater kernel_type=$kernel_type! Mistake?"
  esac
fi
if [[ $add_soft == "1" ]]; then
  to_install="$to_install dbus"
  to_enable="$to_enable dbus"
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install networkmanager networkmanager-openrc"
    to_enable="$to_enable networkmanager"
  fi
  if [[ $ssh == "1" ]]; then
    to_install="$to_install openssh"
    to_enable="$to_enable sshd"
  fi
  if [[ $pipewire == "1" ]]; then
    to_install="$to_install pipewire pipewire-pulse"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluez"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluez"
    to_enable="$to_enable bluetooth"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install cups cups-filters"
    to_enable="$to_enable cupsd"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

[[ -n "$to_install" ]] && $apk_install $to_install
for service in $to_enable; do
  rc-update add "$service" default
done
[[ $networkmanager == "1" ]] &&  addgroup "$user_name" plugdev

msg_print note "Packages are installed."

case "$bootloader_name" in
  grub2)
    to_install="grub"
    [[ $bootloader_type = uefi ]] && to_install="$to_install grub-efi"
    [[ $bootloader_type = bios ]] && to_install="$to_install grub-bios"
    if [[ "$bootloader_bios_place" == *loop* ]]; then
      msg_print warning "$distr can not install GRUB loader to virtual disk. Installation will fail."
    fi
    $apk_install $to_install
    [[ $removable_disk == "1" ]] && msg_print warning "Os-prober can't be installed."
    fs_type=$(grep $'\t''/'$'\t' < /etc/fstab | awk '{print $3;}')
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"modules=sd-mod,usb-storage,$fs_type\"" >> /etc/default/grub
    grub_config
  ;;
  *) msg_print note "Bootloader not chosen."
esac

# Keep more space free
msg_print note "Cleaning up..."
rm -rf /var/cache/apk/*
