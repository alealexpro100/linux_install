#!/bin/bash

if [[ $arch == $arch_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  parse_arch "$qemu_arch"
  if qemu_chroot check $qemu_arch ok; then
    arch_chroot_command="qemu_chroot $qemu_arch"
  else
    exit 1
  fi
fi

CORE_NAME="${CORE_NAME:-core}"
./bin/arch-bootstrap $arch $mirror_archlinux $dir $preinstall

source ./lib/common/common_actions_1.sh
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh"
