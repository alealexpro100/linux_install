
#Debian setup.
msg_print note "Installing addational packages..."

to_install="$postinstall" to_enable=''

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  case $debian_arch in
    i386) kernel_arch=686;;
    *) kernel_arch=$debian_arch;;
  esac
  if [[ $backports_kernel == "1" ]]; then
    $apt_install -t $debian_distr-backports linux-image-$kernel_arch linux-headers-$kernel_arch firmware-linux firmware-linux-nonfree dkms
  else
    to_install="$to_install linux-image-$kernel_arch linux-headers-$kernel_arch firmware-linux firmware-linux-nonfree dkms"
  fi
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install network-manager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-module-bluetooth"
  fi
fi

[[ -n $to_install ]] && $apt_install $to_install
for service in $to_enable; do
  systemctl enable $service
done

msg_print note "Packages are installed."