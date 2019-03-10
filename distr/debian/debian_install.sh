#!/bin/bash
###############################################################
### linux_install script
###
### Copyright (C) 2018 Alexey Nasibulin
###
### By: Alexey Nasibulin (ktifhfl)
###
### License: GPL v3.0
###############################################################

#Fix $PATH for debian.
function arch-chroot-debian() {
  LANG=en_US.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin arch-chroot-fixed $@
}

# Detecting arch and making configuration...
[[ $debian_arch_default != $debian_arch ]] && add_option='--foreign'

mirror_repo_debian=${repo_debian_main#deb*}; mirror_repo_debian=${mirror_repo_debian% \$debian_distr*}
bash ./bin/debootstrap-debian/debootstrap --arch $debian_arch $add_option --include=wget,$preinstall $debian_distr $dir $mirror_repo_debian

echo 'First step is completed.'

# Copying file into rootfs.
echo "All files from rootfs will be copied in new system."
cp -rf ./distr/debian/rootfs/* $dir/
echo -e "$config_installation" >> $dir/root/configuration


echo 'Configuring hosts...'
echo "127.0.0.1	localhost
127.0.1.1	$hostname
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

$HOSTS_ADD" > $dir/etc/hosts
if [[ $setup_script == '1' ]]; then
  echo "Coping installator..."
  cp -rf . $dir/root/linux_install
fi
if [[ $fstab == '1' ]]; then
  echo "Generationg fstab..."
  mv $dir/etc/fstab{,.bk}
  echo '# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

' >> $dir/etc/fstab
  bash ./bin/genfstab -U $dir >> $dir/etc/fstab
fi
# Detecting --foreign key.
if [[ $add_option == "--foreign" ]]; then
  case $debian_arch in
    amd64) qemu_arch=x86_64
    ;;
    arm64) qemu_arch=aarch64
    ;;
    *) qemu_arch=$debian_arch
    ;;
  esac
  [[ $arch != "i368" ]] && cp /usr/bin/qemu-$qemu_arch-static $dir/usr/bin/
  num=0
else
  num=1
fi
echo ''
echo 'Starting scripts for final installantion...'
arch-chroot-debian $dir /root/pi_s$num.sh

case $grub2_type in
  bios)
  arch-chroot-debian $dir /root/bios.sh
    ;;
  uefi)
  arch-chroot-debian $dir /root/uefi.sh
    ;;
  *)
  arch-chroot-debian $dir rm -rf /root/{bios,uefi}.sh
    ;;
esac

if [[ $add_option == "--foreign" && $num == "0" && $arch != "i368" ]]; then
  rm -rf $dir/usr/bin/qemu-$qemu_arch-static
fi
