msg_print note "Copying file into rootfs..."
cp -arf ./lib/distr/$distr/rootfs/* $dir/
cp -af $ALEXPRO100_LIB_LOCATION $dir/root/

msg_print note "Saving configuration..."
[[ -z $LANG ]] && LANG="en_US.UTF-8"
echo -e "LANG=$LANG " >> $dir/root/configuration
for var in ${var_list[@]}; do
  echo -ne "$var=\"${!var}\" " >> $dir/root/configuration
done

msg_print note "Configuring hosts..."
echo "127.0.0.1	localhost
127.0.1.1	$hostname
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

$HOSTS_ADD" >> $dir/etc/hosts

if [[ $copy_setup_script == "1" ]]; then
  msg_print note "Copying installator..."
  cp -arf . $dir/root/linux_install
fi

if [[ $fstab == "1" ]]; then
  msg_print note "Generationg fstab..."
  mv $dir/etc/fstab{,.bak}
  echo '# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

' >> $dir/etc/fstab
  genfstab_light $dir >> $dir/etc/fstab
fi
