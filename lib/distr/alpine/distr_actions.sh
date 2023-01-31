#!/bin/bash

if [[ $arch == $alpine_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  parse_arch "$qemu_arch"
  if qemu_chroot check $qemu_arch ok; then
    arch_chroot_command="qemu_chroot $qemu_arch"
  else
    exit 1
  fi
fi

./bin/alpine-bootstrap $arch $version_alpine $mirror_alpine $dir bash $preinstall

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh"