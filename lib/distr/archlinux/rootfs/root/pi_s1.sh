#!/bin/bash

set -e; cd /root/

#Use library
if [[ -z $ALEXPRO100_LIB_VERSION ]]; then
  if [[ -z $ALEXPRO100_LIB_LOCATION ]]; then
    if [[ -f ${BASH_SOURCE[0]%/*}/alexpro100_lib.sh ]]; then
      ALEXPRO100_LIB_LOCATION="${BASH_SOURCE[0]%/*}/alexpro100_lib.sh"
      echo "Using $ALEXPRO100_LIB_LOCATION."
    else
      echo -e "ALEXPRO100_LIB_LOCATION is not set!"; return 1
    fi
  fi
  source $ALEXPRO100_LIB_LOCATION
fi

echo 'Getting configuration...'
if [[ -z /root/configuration ]]; then
  return_err 'No configuration file!'
else
  source /root/configuration
fi

pacman_command="pacman -Suy --needed --noconfirm"

echo "Making base changes..."
echo $hostname > /etc/hostname
echo "FONT=ter-v16n" >> /etc/vconsole.conf
echo "root:$passwd" | chpasswd
groupadd ssh
useradd -m -g users -G wheel,ssh -s /bin/bash $user_name
echo "$user_name:$passwd" | chpasswd
sed -i '82s|\# \%wheel|\%wheel|' /etc/sudoers

echo "Setting up locales..."
sed -i "s/#en_US.UTF-8/en_US.UTF-8;s/#$LANG/$LANG/" /etc/locale.gen
echo "LANG=$LANG" >> /etc/locale.conf
locale-gen

echo 'Configuring pacman.conf...'
sed -i "s/#Color/Color/" /etc/pacman.conf
[[ $multilib == "1" ]] && sed -i '$!N;s|\#\[multilib\]\n\#Include|\[multilib\]\nInclude|;P;D' /etc/pacman.conf #>_<
mv /etc/pacman.d/mirrorlist{,.bak}
mv /etc/pacman.d/mirrorlist{.used,}

echo "Installing addational packages..."
to_install='' to_enable=''
[[ ! -z $postinstall ]] && to_install="$postinstall"
if [[ $kernel == "1" ]]; then
  to_install="$to_install linux linux-firmware"
fi
if [[ $networkmanager == "1" ]]; then
  to_install="$to_install networkmanager crda"
  to_enable="$to_enable NetworkManager.service"
fi
if [[ $pulseaudio == "1" ]]; then
  to_install="$to_install pulseaudio pulseaudio-alsa"
  [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-bluetooth"
fi
if [[ $bluetooth == "1" ]]; then
  to_install="$to_install bluez bluez-utils"
  to_enable="$to_enable bluetooth.service"
fi
$pacman_command $to_install
for service in $to_enable; do
  systemctl enable $service
done

if [[ $graphics == "1" ]]; then
  echo 'Installing graphics packages...'
  to_install='' to_enable=''
  if [[ $graphics_type == xorg ]]; then
    to_install="$to_install xorg xorg-drivers ttf-droid"
    if [[ $desktop_type == "DE" ]]; then
      case $desktop_de in
        plasma) to_install="$to_install plasma kde-applications";;
        xfce4) to_install="$to_install xfce4 xfce4-goodies";;
        cinnamon) to_install="$to_install cinnamon";;
        gnome) to_install="$to_install gnome gnome-extra";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      if [[ $pulseaudio == "1" ]]; then
        case $desktop_de in 
          xfce4|cinnamon|gnome) to_install="$to_install pavucontrol";;
          plasma);;
        esac
      fi
      if [[ $bluetooth == "1" ]]; then
        case $desktop_de in 
          xfce4|cinnamon) to_install="$to_install blueberry";;
          plasma|gnome) ;;
        esac
      fi
      if [[ $printers == "1" ]]; then
        to_install="$to_install cups foomatic-db foomatic-db-engine print-manager system-config-printer"
        to_install="$to_install foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds"
        to_install="$to_install foomatic-db-ppds cups-pdf cups-filters gutenprint"
        [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
        to_enable="$to_enable org.cups.cupsd.socket"
      fi
    else
      case $desktop_wm in
        icewm) to_install="$to_install icewm";;
        fvwm) to_install="$to_install fvwm";;
        jwm) to_install="$to_install jwm";;
        *) msg_print error "Incorrect paramater $desktop_de! Mistake?";;
      esac
      to_install="$to_install archlinux-xdg-menu"
      [[ $pulseaudio == "1" ]] && to_install="$to_install pulsemixer"
    fi
  else
    msg_print error "Wayland is not supported now!"
  fi
  [[ $firefox_soft == "1" ]] && to_install="$to_install firefox"
  [[ $chromium_soft == "1" ]] && to_install="$to_install chromium"
  [[ $office_soft == "1" ]] && to_install="$to_install libreoffice-fresh poppler poppler-data scribus xreader"
  [[ $admin_soft == "1" ]] && to_install="$to_install gparted gpart exfat-utils dosfstools ntfs-3g"
  case $desktop_dm in
    gdm) to_install="$to_install gdm" to_enable="$to_enable gdm.service";;
    lightdm) to_install="$to_install lightdm-gtk-greeter-settings" to_enable="$to_enable lightdm.service";;
    sddm) to_install="$to_install sddm" to_enable="$to_enable sddm.service";;
  esac
  $pacman_command $to_install
  for service in $to_enable; do
    systemctl enable $service
  done
fi

if [[ $bootloader == "1" ]]; then
  echo 'Installing bootloader...'
  to_install='' to_enable=''
  case $bootloader_name in
    grub2) to_install="$to_install grub";;
    syslinux) to_install="$to_install syslinux";;
    *) msg_print error "Incorrect paramater $bootloader_name! Mistake?";;
  esac
  [[ $bootloader_type = uefi ]] && to_install="$to_install efibootmgr"
  $pacman_command $to_install
  if [[ $removable_disk == "1" && $bootloader_name == "grub2" ]]; then
    $pacman_command -w os-prober
  else
    $pacman_command os-prober
  fi
  if [[ $bootloader_type = uefi ]]; then
    case $bootloader_name in
      grub2) 
      grub-install --target=i386-efi --efi-directory=/boot --removable
      grub-install --target=x86_64-efi --efi-directory=/boot --removable
      grub-mkconfig -o /boot/grub/grub.cfg
      ;;
      syslinux)
      ;;
    esac
  else
    case $bootloader_name in
      grub2) 
      grub-install --target=i386-pc --debug --force $bootloader_bios_place
      grub-mkconfig -o /boot/grub/grub.cfg
      ;;
      syslinux)
      ;;
    esac
  fi
fi
