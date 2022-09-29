#!/bin/bash

if [[ $arch == $debian_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  if qemu_chroot check $arch ok; then
    arch_chroot_command="qemu_chroot $arch"
  else
    exit 1
  fi
fi

[[ $debian_arch != $arch ]] && add_option='--foreign'
export DEBOOTSTRAP_DIR=./bin/debootstrap-debian
DEBOOTSTRAP_BIN="$DEBOOTSTRAP_DIR/debootstrap"
bash -c "$DEBOOTSTRAP_BIN --arch $arch $add_option --include=gnupg,$preinstall $version_debian $dir \"$(echo "${debian_repos[main]}" | cut -d" " -f2)\""
[[ $add_option == "--foreign" ]] && $arch_chroot_command $dir /debootstrap/debootstrap --second-stage

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh" "$dir/root/certs"