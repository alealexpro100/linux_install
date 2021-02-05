./bin/alpine-bootstrap $arch $version_alpine $mirror_alpine $dir sudo bash $preinstall

if [[ $arch == $alpine_arch ]]; then
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
cat ./lib/common/rootfs_scripts/apk_setup.sh >> "$dir/root/pi_s1.sh"
cat ./lib/common/rootfs_scripts/alpine_setup.sh >> "$dir/root/pi_s1.sh"
[[ $bootloader == "1" ]] && cat ./lib/common/rootfs_scripts/bootloader_install/$bootloader_name.sh >> "$dir/root/pi_s1.sh"
chmod +x "$dir/root/pi_s1.sh"
$arch_chroot_command $dir bash /root/pi_s1.sh

rm -rf $dir/root/{pi_s1.sh,configuration,alexpro100_lib.sh}