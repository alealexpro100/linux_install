./bin/arch-bootstrap $arch $mirror_archlinux $dir sudo terminus-font $preinstall

echo 'First step is completed.'

source ./lib/common/common_actions_1.sh

if [[ $arch == $arch_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  if [[ -f /usr/bin/qemu-$qemu_arch-static ]]; then
    arch_chroot_command="qemu_chroot $arch"
  else
    return_err "No /usr/bin/qemu-$qemu_arch-static! Please install qemu-static."
  fi
fi
$arch_chroot_command $dir bash /root/pi_s1.sh

rm -rf $dir/root/{pi_s1.sh,configuration,alexpro100_lib.sh}
