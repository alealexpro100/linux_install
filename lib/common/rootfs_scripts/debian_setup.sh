
#Debian setup.
msg_print note "Installing addational packages..."

to_install='' to_enable=''

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  [[ $backports_kernel == "1" ]] && ADD_conf="-t $debian_distr-backports"
  case $debian_arch in
    i386) kernel_arch=686;;
    *) kernel_arch=$debian_arch;;
  esac
  $apt_install $ADD_conf linux-image-$kernel_arch linux-headers-$kernel_arch firmware-linux firmware-realtek firmware-atheros firmware-brcm80211 dkms
  $apt_install -d $ADD_conf r8168-dkms
fi

if [[ $add_soft == "1" ]]; then
  if [[ $networkmanager == "1" ]]; then
    to_install="$to_install network-manager"
  fi
  if [[ $pulseaudio == "1" ]]; then
    to_install="$to_install pulseaudio"
    [[ $bluetooth == "1" ]] && to_install="$to_install pulseaudio-module-bluetooth"
  fi
  if [[ $bluetooth == "1" ]]; then
    to_install="$to_install bluetooth"
  fi
  if [[ $printers == "1" ]]; then
    to_install="$to_install task-print-server"
    to_install="$to_install foomatic-db cups-pdf"
    [[ $bluetooth == "1" ]] && to_install="$to_install bluez-cups"
  fi
fi

[[ -n $to_install ]] && $apt_install $to_install
for service in $to_enable; do
  systemctl enable $service
done

msg_print note "Packages are installed."