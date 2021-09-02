#!/bin/bash

# shellcheck disable=SC2046
read_param "" "$M_LANG_SYSTEM" "$LANG_SYSTEM" LANG_SYSTEM menu_var $(echo -e "en_US.UTF-8\n$LANG_SYSTEM" | gen_menu)
read_param "" "$M_HOSTNAME" "${distr:?}-$RANDOM" hostname text
read_param "" "$M_USER" "${user_name:?}" user_name text
read_param "" "$M_SHELL" "${user_shell:?}" user_shell text
read_param "" "$M_PASS" '' passwd secret_empty
if [[ -z $passwd ]]; then
  add_var "declare -gx" passwd "${passwd_default:?}"
  print_param warning "$M_PASS_NO $passwd."
fi
if mountpoint -q "${dir:?}"; then
  if [[ $LIVE_MODE == "1" ]]; then
    ECHO_MODE_TMP=$ECHO_MODE
    ECHO_MODE=auto
  fi
  read_param "" "$M_FSTAB" '' fstab yes_or_no
  read_param "" "$M_BOOTLOADER" '' bootloader yes_or_no
  # shellcheck disable=SC2154
  if [[ $bootloader == "1" ]]; then
    read_param "" "$M_KERNEL" '' kernel yes_or_no
    if [[ -d /sys/firmware/efi/efivars ]]; then
      BOOTLOADER_TYPE_DEFAULT=${BOOTLOADER_TYPE_DEFAULT:-uefi}
    else
      BOOTLOADER_TYPE_DEFAULT=${BOOTLOADER_TYPE_DEFAULT:-bios}
    fi
    # shellcheck disable=SC2046
    read_param "" "$M_BOOTLOADER_TYPE" "$BOOTLOADER_TYPE_DEFAULT" bootloader_type menu_var $(echo -e "bios\nuefi" | gen_menu)
    if [[ ${bootloader_type:?} == "uefi" && $(findmnt -funcevo FSTYPE "$dir/boot") != vfat ]]; then
      print_param error "$M_BOOTLOADER_UEFI_VFAT_NO \"$dir/boot\"!"
    fi
    read_param "" "$M_BOOTLOADER_NAME" "grub2" bootloader_name menu_var $(echo -e "grub2" | gen_menu)
    [[ $bootloader_type == bios ]] && read_param "" "$M_BOOTLOADER_PATH" "${bootloader_bios_place:-$(findmnt -funcevo SOURCE "$dir")}" bootloader_bios_place text
    if [[ $LIVE_MODE == "1" ]]; then
      ECHO_MODE=$ECHO_MODE_TMP
      unset ECHO_MODE_TMP
    else
      read_param "" "$M_BOOTLOADER_REMOVABLE" '' removable_disk no_or_yes
    fi
    read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
  fi
else
  add_var "declare -gx" "bootloader" "0"
  read_param "" "$M_KERNEL" '' kernel no_or_yes
  read_param "" "$M_ADD_SOFT" '' add_soft no_or_yes
fi

[[ $LIVE_MODE == "1" ]] || read_param "" "$M_COPYSCRIPT" '' copy_setup_script yes_or_no

parse_arch "$(uname -m)"