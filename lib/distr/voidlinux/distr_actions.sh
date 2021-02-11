[[ "$void_add_i386" == "1" && ! $version_void == "musl" ]] && preinstall="$preinstall void-repo-multilib void-repo-multilib-nonfree"
./bin/void-bootstrap $arch $version_void $mirror_voidlinux $dir base-voidstrap $preinstall void-repo-nonfree

if [[ $arch == $void_arch ]]; then
  arch_chroot_command="chroot_rootfs auto"
else
  if qemu_chroot check $arch ok; then
    arch_chroot_command="qemu_chroot $arch"
  else
    exit 1
  fi
fi
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
echo -e "tmpfs\t/tmp\ttmpfs\tdefaults,nosuid,nodev\t0 0\n" >> /etc/fstab
cat ./lib/common/rootfs_scripts/xbps_setup.sh >> "$dir/root/pi_s1.sh"
cat ./lib/common/rootfs_scripts/void_setup.sh >> "$dir/root/pi_s1.sh"
[[ $bootloader == "1" ]] && cat ./lib/common/rootfs_scripts/bootloader_install/$bootloader_name.sh >> "$dir/root/pi_s1.sh"
chmod +x "$dir/root/pi_s1.sh"
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh"