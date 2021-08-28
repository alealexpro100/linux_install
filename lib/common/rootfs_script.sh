#!/bin/bash

function base_setup() {
  msg_print note "Setting up hostname and configuring user..."
  echo "$hostname" > /etc/hostname
  echo "root:$passwd" | chpasswd -c SHA512
  case "$1" in
    glibc) 
      useradd -m -g users -G "$user_groups" -s "$user_shell" "$user_name"
    ;;
    musl) 
      adduser -G users -s "$user_shell" -D "$user_name"
      for group_name in $user_groups; do 
        addgroup "$user_name" "$group_name"
      done
    ;;
    *) return_err "Incorrect type $1!";;
  esac
  echo  "$user_name:$passwd" | chpasswd -c SHA512
}

function locale_setup() {
  msg_print note "Setting up locales..."
  sed -ie "s/#\s\?$LANG_SYSTEM/$LANG_SYSTEM/" /etc/locale.gen
  echo "LANG=\"$LANG_SYSTEM\"" >> "$1"
  locale-gen
}

function locale_setup_voidlinux() {
  msg_print note "Setting up locales..."
  sed -ie "s/#\s\?$LANG_SYSTEM/$LANG_SYSTEM/" /etc/default/libc-locales
  sed -ie "1s/en_US.UTF-8/$LANG_SYSTEM/" "$1"
  xbps-reconfigure -f glibc-locales
}

function grub_config() {
  if [[ $bootloader_type = uefi ]]; then
    grub-install --target=i386-efi --efi-directory=/boot --removable $grub_param
    grub-install --target=x86_64-efi --efi-directory=/boot --removable $grub_param
  else
    grub-install --target=i386-pc --force $grub_param $bootloader_bios_place
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}
