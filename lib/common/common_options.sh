read_param "" "$M_HOSTNAME" "$distr-$RANDOM" hostname text
read_param "" "$M_USER" "$user_name" user_name text
read_param "" "$M_SHELL" "$user_shell" user_shell text
read_param "" "$M_PASS" '' passwd secret_empty
if [[ -z $passwd ]]; then
  add_var "declare -gx" passwd "$passwd_default"
  print_param warning "$M_PASS_NO $passwd."
fi
if mountpoint -q "$dir" && [[ $(findmnt -funcevo SOURCE "$dir") != tmpfs ]]; then
  read_param "" "$M_FSTAB" '' fstab yes_or_no
  read_param "" "$M_BOOTLOADER" '' bootloader yes_or_no
  if [[ $bootloader == "1" ]]; then
    if [[ -d /sys/firmware/efi/efivars ]]; then
      BOOTLOADER_TYPE_DEFAULT=${BOOTLOADER_TYPE_DEFAULT:-uefi}
    else
      BOOTLOADER_TYPE_DEFAULT=${BOOTLOADER_TYPE_DEFAULT:-bios}
    fi
    read_param "" "$M_BOOTLOADER_TYPE (bios/uefi)" "$BOOTLOADER_TYPE_DEFAULT" bootloader_type text_check bios,uefi
    if [[ $bootloader_type == "uefi" && $(findmnt -funcevo FSTYPE "$dir/boot") != vfat ]]; then
      print_param warning "No vfat partition found on \"$dir/boot\"!\nWithout it system won't be installed!"
    fi
    read_param "" "$M_BOOTLOADER_NAME (grub2/refind)" "grub2" bootloader_name text
    #Get parent disk of partition.
    [[ $bootloader_type == bios ]] && read_param "" "$M_BOOTLOADER_PATH" "/dev/$(lsblk --noheadings --output pkname "$(findmnt -funcevo SOURCE "$dir")")" bootloader_bios_place text
    [[ $LIVE_MODE == "1" ]] || read_param "" "$M_BOOTLOADER_REMOVABLE" '' removable_disk no_or_yes
  fi
else
  bootloader=0
fi

[[ $LIVE_MODE == "1" ]] || read_param "" "$M_COPYSCRIPT" '' copy_setup_script yes_or_no

parse_arch $(uname -m)