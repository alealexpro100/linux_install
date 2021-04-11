
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
mirror_repo_debian=${debian_repos[main]#deb*};
mirror_repo_debian=${mirror_repo_debian% \$version_debian*}
export DEBOOTSTRAP_DIR=./bin/debootstrap-debian
bash ./bin/debootstrap-debian/debootstrap --arch $arch $add_option --include=wget,$preinstall $version_debian $dir $mirror_repo_debian
[[ $add_option == "--foreign" ]] && $arch_chroot_command $dir /debootstrap/debootstrap --second-stage

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source ./lib/common/common_actions_1.sh
$arch_chroot_command "$dir" bash /root/pi_s1.sh

rm -rf "$dir/root/pi_s1.sh" "$dir/root/configuration" "$dir/root/alexpro100_lib.sh" "$dir/root/certs"