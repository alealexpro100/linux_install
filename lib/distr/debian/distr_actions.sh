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

[[ $debian_arch != $arch ]] && deb_add_option="$deb_add_option --foreign"
[[ -z $preinstall ]] || preinstall=",$preinstall"
debootstrap_component="${debian_repos_order[0]}"
bash -c "debootstrap --arch $arch $deb_add_option --include=gnupg$preinstall $version_debian $dir \"$(echo "${debian_repos[$debootstrap_component]}" | cut -d" " -f2)\""
[[ $debian_arch != $arch ]] && $arch_chroot_command $dir /debootstrap/debootstrap --second-stage

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh" "$dir/root/LI_certs"