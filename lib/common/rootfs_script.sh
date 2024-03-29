#!/bin/bash

function base_setup() {
  msg_print note "Setting up hostname and configuring user..."
  echo "$hostname" > /etc/hostname
  echo "root:$passwd" | chpasswd -c SHA512
  user_groups="${user_groups:-users}"
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

function setup_sudo() {
  if [[ ! -d /etc/sudoers.d ]]; then
    msg_print warning "Looks like sudo is not installed. Will create directory '/etc/sudoers.d'."
    mkdir -m 0755 /etc/sudoers.d
  fi
  echo "%sudo ALL=(ALL) ALL" > /etc/sudoers.d/10-installer
  chmod 0440 /etc/sudoers.d/10-installer
}

function grub_config() {
  if [[ $bootloader_type = uefi ]]; then
    removable_add=""
    [[ $removable_add != "1" ]] || removable_add="--removable"
    [[ -f /usr/lib/grub/i386-efi/modinfo.sh ]] && grub-install --target=i386-efi --efi-directory=/boot --removable $grub_param
    grub-install --target=x86_64-efi --efi-directory=/boot $removable_add $grub_param
  else
    grub-install --target=i386-pc --force $grub_param $bootloader_bios_place || grub_fail=1
    # May be GRUB bug. See https://askubuntu.com/questions/895632
    if [[ $grub_fail == "1" ]]; then
      msg_print warning "GRUB bug detected. See Debian bug 866603.\nDisabling metadata_csum_seed and trying again."
      tune2fs -O ^metadata_csum_seed $bootloader_bios_place
      grub-install --target=i386-pc --force $grub_param "$(mount | sed -n "s|\(^/dev/.*\) on ${dir} .*|\1|p")"
    fi
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}
