
#Debian setup.
msg_print note "Installing addational packages..."

if [[ $kernel == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  [[ $backports_kernel == "1" ]] && ADD_conf="-t $debian_distr-backports"
  case $debian_arch in
    i386) kernel_arch=686;;
    *) kernel_arch=$debian_arch;;
  esac
  $apt_install $ADD_conf console-setup-linux linux-image-$kernel_arch linux-headers-$kernel_arch firmware-linux firmware-realtek firmware-atheros firmware-brcm80211 dkms
  $apt_install -d $ADD_conf r8168-dkms
fi

to_install='' to_enable=''
if [[ $networkmanager == "1" ]]; then
  to_install="$to_install network-manager"
fi
$apt_install $to_install

msg_print note "Packages are installed."