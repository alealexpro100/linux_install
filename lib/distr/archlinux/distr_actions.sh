./bin/arch-bootstrap $arch $mirror_archlinux $dir sudo terminus-font $preinstall

echo 'First step is completed.'

source ./lib/common/common_actions_1.sh
cat ./lib/common/rootfs_scripts/pacman_setup.sh >> $dir/root/pi_s1.sh
cat ./lib/common/rootfs_scripts/arch_setup.sh >> $dir/root/pi_s1.sh

if [[ $arch == $arch_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  if qemu_chroot check $arch ok; then
    arch_chroot_command="qemu_chroot $arch"
  else
    exit 1
  fi
fi
chmod +x $dir/root/pi_s1.sh
$arch_chroot_command $dir bash /root/pi_s1.sh

rm -rf $dir/root/{pi_s1.sh,configuration,alexpro100_lib.sh}
