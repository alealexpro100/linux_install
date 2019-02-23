#!/bin/bash

./bin/arch-bootstrap ./bin/arch-chroot $arch $mirror_archlinux $dir base sudo $preinstall

echo 'First step is completed.'

# Copying file into rootfs.
echo "All files from rootfs will be copied in new system."
cp -rf ./distr/$distr/rootfs/* $dir/
echo -e "LANG=$LANG $config_installation" >> $dir/root/configuration
echo 'Configuring hosts...'
echo "127.0.0.1	localhost
127.0.1.1	$hostname
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

$HOSTS_ADD" > $dir/etc/hosts
if [[ $setup_script == 1 ]]; then
  echo "Coping installator..."
  cp -rf . $dir/root/linux_install
fi
if [[ $fstab == 1 ]]; then
  echo "Generationg fstab..."
  mv $dir/etc/fstab{,.bk}
  echo '# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

' >> $dir/etc/fstab
  bash ./bin/genfstab -U $dir > $dir/etc/fstab
fi
echo ''
echo 'Starting scripts for final installantion...'

#Detect host arch, parse it and setup qemu-emulation.
case $(uname -m) in
  i?86) host_arch=i686;;
  x86_64|amd64) host_arch=x86_64;;
  aarch64|arm64) host_arch=aarch64;;
  *) host_arch=$(uname -m);;
esac

if [[ "$host_arch" != "$arch" ]]; then
  case $arch in
    i?86) qemu_arch=i386;;
    *) qemu_arch=$arch;;
  esac
fi

# Fix non-mounpoint directory.
if ! mountpoint -q "$dir"; then
  mount --bind $dir $dir
  change_mount=1
fi

# Only here we use arch-chroot.
arch_chroot_command=./bin/arch-chroot
if [[ $qemu_arch == "i386" && $host_arch == "x86_64" ]]; then
  arch_chroot_command="linux32 $arch_chroot_command" qemu_arch=""
fi

if [[ ! -z $qemu_arch ]]; then
  cp /usr/bin/qemu-$qemu_arch-static $dir/usr/bin/
fi

$arch_chroot_command $dir /root/pi_s1.sh || echo "OK"

if [[ $grub2 == '1' ]]; then
  case $grub2_type in
    bios)
    $arch_chroot_command $dir /root/bios.sh || echo "OK"
      ;;
    uefi)
    $arch_chroot_command $dir /root/uefi.sh || echo "OK"
      ;;
  esac
else
  $arch_chroot_command $dir rm -rf /root/{bios,uefi}.sh || echo "OK"
fi

if [[ ! -z $qemu_arch ]]; then
  rm -rf $dir/usr/bin/qemu-$qemu_arch-static
fi

#Revert changes for directory.
[[ $change_mount == 1 ]] && umount $dir
