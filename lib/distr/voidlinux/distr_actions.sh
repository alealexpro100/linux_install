#!/bin/bash

if [[ $arch == $void_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  parse_arch "$qemu_arch"
  if qemu_chroot check $qemu_arch ok; then
    arch_chroot_command="qemu_chroot $qemu_arch"
  else
    exit 1
  fi
fi

[[ "$void_add_i386" == "1" && $version_void == "glibc" ]] && preinstall="$preinstall void-repo-multilib void-repo-multilib-nonfree"
./bin/void-bootstrap $arch $version_void $mirror_voidlinux $dir base-voidstrap $preinstall void-repo-nonfree

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
echo -e "tmpfs\t/tmp\ttmpfs\tdefaults,nosuid,nodev\t0 0\n" >> "$dir/etc/fstab"
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh"