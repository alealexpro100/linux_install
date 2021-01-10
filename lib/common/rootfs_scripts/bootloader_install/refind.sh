
# Bootloader install.
msg_print note "Installing $bootloader_name..."

if [[ $removable_disk == "1" ]]; then
  refind_options="--usedefault  $(findmnt -funcevo SOURCE /boot)"
else
  refind_options=""
fi
case $distr in
  archlinux) 
    $pacman_install refind
    refind-install $refind_options
  ;;
  debian) 
    $apt_install refind
    refind-install $refind_options
  ;;
  *)
  msg_print error "$bootloader_name installation is not supported for $distro. Skipping."
  ;;
esac

msg_print note "Installed $bootloader_name."