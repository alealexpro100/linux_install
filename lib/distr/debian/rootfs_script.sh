#!/bin/bash

user_groups="audio,video,input,sudo"
base_setup glibc
locale_setup /etc/default/locale

#Apt config
msg_print note "Apt setup..."
declare -gx DEBIAN_FRONTEND=noninteractive
apt_install="apt-get -y install"
[[ $debian_no_recommends == 1 ]] && apt_install="$apt_install --no-install-recommends"

[[ $debian_add_i386 == "1" ]] && dpkg --add-architecture i386
rm -rf /etc/apt/sources.list
for repo_name in "${debian_repos_order[@]}"; do
  [[ -n "${debian_repos[$repo_name]}" ]] || continue
  echo -e "#Repository $repo_name\n${debian_repos[$repo_name]}\n" >> /etc/apt/sources.list
  if [[ -f "/root/certs/$repo_name.key" ]]; then
    if is_binary "/root/certs/$repo_name.key"; then
      cp "/root/certs/$repo_name.key" "/etc/apt/trusted.gpg.d/$repo_name.gpg"
    else
      gpg --no-default-keyring --keyring "gnupg-ring:/etc/apt/trusted.gpg.d/$repo_name.gpg" --import < "/root/certs/$repo_name.key"
    fi
    chmod 644 "/etc/apt/trusted.gpg.d/$repo_name.gpg"
  fi
done
apt-get update
# By default update repo contains additional updates
apt-get upgrade -y

msg_print note "Apt-get is ready."

#Debian setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

#Network setup.
if [[ $networkmanager != "1" ]]; then
  msg_print note "Using default network config."
  echo -e "auto eth0\n\tallow-hotplug eth0\n\tiface eth0 inet dhcp\n\tiface eth0 inet6 auto" >> /etc/network/interfaces.d/net
  msg_print warning "Masking udev's network renaming rule."
  ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
  to_enable="$to_enable networking"
fi

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  case $debian_arch in
    i386) kernel_arch=686;;
    *) kernel_arch=$debian_arch;;
  esac
  if [[ $backports_kernel == "1" ]]; then
    case "$kernel_type" in
      vanilla) $apt_install -t "$version_debian-backports" "linux-image-$kernel_arch" firmware-linux;;
      virtual) $apt_install -t "$version_debian-backports" "linux-image-$kernel_arch";;
      *) return_err "Incorrect paramater kernel_type=$kernel_type! Mistake?"
    esac
  else
    case "$kernel_type" in
      vanilla) to_install="$to_install linux-image-$kernel_arch firmware-linux";;
      virtual) to_install="$to_install linux-image-$kernel_arch";;
      *) return_err "Incorrect paramater kernel_type=$kernel_type! Mistake?"
    esac
  fi
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install network-manager"
  fi
  if [[ $ssh == "1" ]]; then
    to_install="$to_install ssh"
    to_enable="$to_enable ssh"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-module-bluetooth"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluetooth"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install cups printer-driver-all"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

if [[ $graphics == "1" ]]; then
  case $graphics_type in
    xorg)
      to_install="$to_install xorg"
      case $desktop_type in
        DE)
          case $desktop_de in
            plasma) to_install="$to_install task-kde-desktop";;
            xfce4) to_install="$to_install task-xfce-desktop";;
            cinnamon) to_install="$to_install task-cinnamon-desktop";;
            gnome) to_install="$to_install task-gnome-desktop";;
            *) return_err "Incorrect paramater desktop_de=$desktop_de! Mistake?";;
          esac
          if [[ $pulseaudio == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon|gnome) to_install="$to_install pavucontrol";;
            esac
          fi
          if [[ $bluetooth == "1" ]]; then
            case $desktop_de in 
              xfce4|cinnamon) to_install="$to_install blueman";;
            esac
          fi
        ;;
        *)
          return_err "Wrong parameter desktop_type=$desktop_type. Mistake?"
        ;;
      esac
    ;;
    wayland)
      to_install="$to_install egl-wayland"
      case $desktop_type in
        DE)
          case $desktop_de in
            plasma) to_install="$to_install task-kde-desktop plasma-workspace-wayland";;
            gnome) to_install="$to_install task-gnome-desktop";;
            *) return_err "Incorrect paramater desktop_de=$desktop_de! Mistake?";;
          esac
          if [[ $pulseaudio == "1" ]]; then
            case $desktop_de in 
              gnome) to_install="$to_install pavucontrol";;
            esac
          fi
        ;;
        *)
          return_err "Wrong parameter desktop_type=$desktop_type. Mistake?"
        ;;
      esac
    ;;
    *)
      return_err "Wrong parameter graphics_type=$graphics_type. Mistake?"
    ;;
  esac
fi

[[ -n $to_install ]] && $apt_install $to_install
for service in $to_enable; do
  systemctl enable "$service"
done

msg_print note "Packages are installed."

case "$bootloader_name" in
  grub2)
    [[ $bootloader_type = uefi ]] && to_install="grub-efi"
    [[ $bootloader_type = bios ]] && to_install="grub-pc"
    $apt_install $to_install
    if [[ $removable_disk == "0" ]]; then
      apt -y remove os-prober;
    fi
    grub_config
  ;;
  *) msg_print note "Bootloader not chosen."
esac

# Keep more space free
msg_print note "Cleaning up..."
apt-get clean
