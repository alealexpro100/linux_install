#!/bin/bash

#######################################
#       Initial install script.       #
#       Parses dirs from ./distr      #
#       and ask some options          #
#######################################
set -e

# Only root can run this script.
if [[ $UID != 0 ]]; then
  echo 'This script requries root permissions!'
  exit 1
fi

#Clear vars.
config_installation='' OLD_DIR=''

if ! [[ -f ./version_install ]]; then
  echo 'Please, change directory.'
fi

# Function to adopt arch-chroot script.
function arch-chroot() {
  # Fix non-mounpoint directory.
  if ! mountpoint -q "$dir"; then
    mount --bind $dir $dir
    change_mount=1
  else
    change_mount=0
  fi

  if [[ $arch == "i686" || $debian_arch == "i386" ]]; then
    linux32 ./bin/arch-chroot $@
  else
    ./bin/arch-chroot $@
  fi

  [[ $change_mount == 1 ]] && umount $dir

  return 0
}

# ...and private_parametres.
if [[ -f ./private_parametres ]]; then
  source ./private_parametres
else
  source ./public_parametres
fi

#Detecting auto_parametrers...
if [[ -f $1 ]]; then
  function add_var {
    config_installation="$config_installation\n$1=\"$2\""
    export $1="$2"
  }
  source $1 || exit 1
  source ./distr/$distr/${distr}_install.sh || echo "Ok.."
  echo "Installed $distr with $1 to $dir."
  exit 0
fi

# Big function for reading option with parametres.
# Example: *read_param 'Enter smth: ' smth yes_or_no* will add to var config smth=...
# Plan: add ncurses support and GUI.
function read_param() {
  dialog=$1 default_var=$2 var=$3 option=$4
  # CLI MODE.
  if [[ $echo_mode = '' || $echo_mode = 'cli' ]]; then
    case $option in
      yes_or_no)
      read -e -p "$dialog"  -i "$default_var" tmp
      if [[ $tmp == 'Y' || $tmp == 'y' || $tmp == 'Yes' || $tmp == 'yes' || $tmp == '' ]]; then
        tmp=1
      else
        tmp=0
      fi
      ;;
      no_or_yes)
      read -e -p "$dialog"  -i "$default_var" tmp
      if [[ $tmp == 'N' || $tmp == 'n' || $tmp == 'No' || $tmp == 'no' || $tmp == '' ]]; then
        tmp=0
      else
        tmp=1
      fi
      ;;
      text)
      while [[ $tmp == '' ]]; do
        read -e -p "$dialog"  -i "$default_var" tmp
      done
      ;;
      text_empty)
        read -e -p "$dialog"  -i "$default_var" tmp
      ;;
      pass)
      read -e -s -p "$dialog" -i "$default_var" tmp
      if [[ -z $tmp ]]; then
        echo -e "\n[\e[0;33mWARNING\e[m] You haven't enter password. Your default password will be 'pass'."
        tmp=pass
      else
        echo ''
      fi
      ;;
      *)
      echo "Option $option is incorrect!"
      exit 1;
      ;;
    esac
    config_installation="$config_installation\n$var=\"$tmp\""
    export $var="$tmp"
    tmp=''
  fi
}

echo 'This script supposes that directory for installantion is prepared.'

# Get standart options.

#Get distribution variable.
echo "This is script for installing linux. Choose distribution for installing, please."
echo -e "Avaliable distributions: \n$(ls -1 ./distr)"
read_param "Distribution: " "" distr text
while [[ ! -d ./distr/$distr && $distr=='' ]]; do
  read_param "Distribution: " "" distr text
done

# Getting some standart options for all distributions.
read_param "Enter the path to install $distr: " "/mnt/mnt" dir text
read_param "Enter hostname: " "$distr" hostname text
read_param "Enter name of user: " "alexey" user_name text
read_param "Enter password for root and $user_name: " "" passwd pass
if mountpoint -q "$dir" && [[ $(findmnt -funcevo SOURCE $dir) != tmpfs ]]; then
  read_param "Do you want to generate fstab? (Y/n): " '' fstab yes_or_no
  read_param "Do you want to install bootloader (grub2)? (Y/n): " '' grub2 yes_or_no
  if [[ $grub2 == 1 ]]; then
    if [[ -d /sys/firmware/efi/efivars ]]; then
      grub2_type=uefi
    else
      grub2_type=bios
    fi
    read_param "Enter type of bootloader (bios/uefi): " "$grub2_type" grub2_type text
    [[ $grub2_type == bios ]] && read_param "Enter where to install bootloader: " "$(findmnt -funcevo SOURCE $dir)" grub2_bios_place text
    read_param "Do you want to install $distr to flash disk (don't create other items in GRUB2)? (N/y): " '' flash_disk no_or_yes
  fi
fi
read_param "Do you want to install graphics (X-server, XFCE desktop and lightDM)? (Y/n): " '' graph yes_or_no
[[ $graph == 1 ]] && read_param "Do you want to add LightDM to autostart? (Y/n): " '' lightdm_autostart yes_or_no
read_param "Do you want to copy this setup utitlity in new OS? (Y/n): " ""  setup_script yes_or_no

add_option=''

source ./distr/$distr/${distr}.sh

# =)
echo "Script succesfully ended its work. Have a nice day!"
exit 0
