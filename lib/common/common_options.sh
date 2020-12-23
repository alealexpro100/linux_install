msg_print note "Common options:"
read_param "Enter the path to install $distr: " "/mnt/mnt" dir text
read_param "Enter hostname: " "$distr-$RANDOM" hostname text
read_param "Enter name of user: " "$user_name" user_name text
read_param "Enter shell for user: " "$user_shell" user_shell text
read_param "Enter password: " '' passwd secret_empty
if [[ -z $passwd ]]; then
  var_list[passwd]="declare -gx passwd=$passwd_default"
  msg_print warning "No password entered. Password set to $passwd."
fi
if mountpoint -q "$dir" && [[ $(findmnt -funcevo SOURCE $dir) != tmpfs ]]; then
  read_param "Do you want to generate fstab? (Y/n): " '' fstab yes_or_no
  read_param "Do you want to install bootloader? (Y/n): " '' bootloader yes_or_no
  if [[ $bootloader == "1" ]]; then
    if [[ -d /sys/firmware/efi/efivars ]]; then
      bootloader_type_default=uefi
    else
      bootloader_type_default=bios
    fi
    while ! [[ $bootloader_type == "bios" || $bootloader_type == "uefi" ]]; do
      read_param "Enter type of bootloader (bios/uefi): " "$bootloader_type_default" bootloader_type text
    done
    [[ $bootloader_type == bios ]] && read_param "Enter where to install bootloader: " "$(findmnt -funcevo SOURCE $dir)" bootloader_bios_place text
    read_param "Do you want to install $distr to removable disk? (N/y): " '' removable_disk no_or_yes
  fi
else
  bootloader=0
fi
#read_param "Do you want to install graphics? (Y/n): " '' graphics yes_or_no
#[[ $graphics == "1" ]] && read_param "Do you want to install and add display manager to autostart? (Y/n): " '' dm_install yes_or_no
read_param "Do you want to copy this setup utitlity to new OS? (Y/n): " '' copy_setup_script yes_or_no
