#!/bin/bash

user_groups="audio,video,input,sudo"
base_setup glibc
locale_setup /etc/default/locale

#Apt config
msg_print note "Apt setup..."
declare -gx DEBIAN_FRONTEND=noninteractive
apt_install="apt -y install"
[[ $debian_no_recommends == 1 ]] && apt_install="$apt_install --no-install-recommends"

for repo_name in "${debian_repos_order[@]}"; do
  [[ -n "${debian_repos[$repo_name]}" && $repo_name != "main" ]] || continue
  echo -e "#Repository $repo_name\n${debian_repos[$repo_name]}\n" >> /etc/apt/sources.list
  if [[ -f "/root/LI_certs/$repo_name.key" ]]; then
    gpg --no-default-keyring --keyring "gnupg-ring:/etc/apt/trusted.gpg.d/$repo_name.gpg" --import < "/root/certs/$repo_name.key"
    chmod 644 "/etc/apt/trusted.gpg.d/$repo_name.gpg"
  fi
done
apt update
# By default update repo contains additional updates
apt upgrade -y

msg_print note "Apt is ready."

#Debian setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

#Network setup.
if [[ $networkmanager != "1" ]]; then
  msg_print note "Using default network config."
  echo -e "auto eth0\n\tallow-hotplug eth0\n\tiface eth0 inet dhcp\n\tiface eth0 inet6 auto" >> /etc/network/interfaces.d/net
  to_enable="networking"
fi

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  case "$kernel_type" in
    vanilla) to_install="$to_install linux-5.10-generic linux-headers-5.10-generic linux-firmware dkms";;
    virtual) to_install="$to_install linux-5.10-generic";;
    *) return_err "Incorrect paramater kernel_type=$kernel_type! Mistake?"
  esac
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install network-manager"
  fi
  if [[ $ssh == "1" ]]; then
    to_install="$to_install ssh"
    to_enable="$to_enable ssh"
  fi
  if [[ $graphics == "1" ]]; then
    to_install="$to_install xorg-all-main astra-extra fly-all-main firefox"
    [[ $bootloader_name == grub2 ]] && to_install="$to_install desktop-base"
    [[ $networkmanager == "1" ]] && to_install="$to_install network-manager-gnome"
  fi
fi

# Bunch of fixes. Their repo is pretty broken.
# These steps fix installaion (do NOT merge them)

[[ $kernel == "1" ]] && $apt_install initramfs-tools
[[ $graphics == "1" ]] && $apt_install samba

[[ -n $to_install ]] && $apt_install $to_install
for service in $to_enable; do
  systemctl enable "$service"
done

# It is required because of 'security'. It wil not work otherwise
msg_print note "Setting up admin user..."
groupadd -g 1001 astra-admin
[[ $graphics == "1" ]] && usermod -aG astra-console "$user_name"
usermod -aG astra-admin "$user_name"

msg_print note "Packages are installed."

case "$bootloader_name" in
  grub2)
    [[ $bootloader_type = uefi ]] && to_install="grub-efi"
    [[ $bootloader_type = bios ]] && to_install="grub-pc"
    $apt_install $to_install
    grub_config
  ;;
  *) msg_print note "Bootloader not chosen."
esac

# Keep more space free
msg_print note "Cleaning up..."
apt-get clean
