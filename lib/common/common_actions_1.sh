#!/bin/bash

msg_print note "Copying files into rootfs..."
[[ -d ./lib/distr/$distr/rootfs ]] && $cp_safe "./lib/distr/$distr/rootfs/." "$dir"

msg_print note "Saving configuration..."
[[ ! -d "$dir/root" ]] && mkdir "$dir/root"
cp -af "$ALEXPRO100_LIB_LOCATION" "$dir/root/"
var_export "add_var " > "$dir/root/configuration"
msg_print note "Creating config script..."
{
  echo -ne "#!/bin/bash\n\nset -e; cd /root/\n"
  cat ./lib/common/lib_connect.sh
  cat ./lib/common/lib_var_op.sh
  echo -e "\nsource /root/configuration"
  cat ./lib/common/rootfs_script.sh
  cat ./lib/distr/$distr/rootfs_script.sh
} > "$dir/root/pi_s1.sh"
chmod +x "$dir/root/pi_s1.sh"

msg_print note "Configuring hosts..."
echo "127.0.0.1	localhost
127.0.1.1	$hostname
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

$HOSTS_ADD" >> "$dir/etc/hosts"

if [[ $copy_setup_script == "1" ]]; then
  msg_print note "Copying installator..."
  $cp_safe . "$dir/root/linux_install"
fi

if [[ $fstab == "1" ]]; then
  msg_print note "Generationg fstab..."
  [[ -f $dir/etc/fstab ]] && mv "$dir/etc/fstab" "$dir/etc/fstab.bak"
  echo -e '# Static information about the filesystems.
# See fstab(5) for details.\n
# <file system> <dir> <type> <options> <dump> <pass>' >> "$dir/etc/fstab"
  genfstab_light "$dir" >> "$dir/etc/fstab"
fi

msg_print note "Starting distr step..."