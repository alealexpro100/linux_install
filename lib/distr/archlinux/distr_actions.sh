
if [[ $arch == $arch_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  if qemu_chroot check $arch ok; then
    arch_chroot_command="qemu_chroot $arch"
  else
    exit 1
  fi
fi

./bin/arch-bootstrap $arch $mirror_archlinux $dir $preinstall

source ./lib/common/common_actions_1.sh
{
  cat ./lib/common/rootfs_scripts/pacman_setup.sh
  cat ./lib/common/rootfs_scripts/arch_setup.sh
  [[ $bootloader == "1" ]] && cat ./lib/common/rootfs_scripts/bootloader_install/$bootloader_name.sh
} >> "$dir/root/pi_s1.sh"
chmod +x "$dir/root/pi_s1.sh"
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh"
