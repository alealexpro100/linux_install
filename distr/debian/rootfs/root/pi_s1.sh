#!/bin/bash

#Preconfiguration
set -e
cd /root/
echo "Getting configuration..."
if [[ -z /root/configuration ]]; then
  echo "[ERROR] No configuration file! Exiting."
  exit 1
else
  source /root/configuration
fi

echo "Setting up hostname..."
echo $hostname >> /etc/hostname

echo "Changing root password..."
echo "root:$passwd" | chpasswd

echo "Creating user $user_name..."
groupadd ssh
useradd -m -g users -G sudo,ssh,video,input -s /bin/bash $user_name
echo  "$user_name:$passwd" | chpasswd

echo "Configuring sources.list..."
rm -rf /etc/apt/sources.list
for repo_name in repo_debian_main repo_debian_updates repo_debian_security repo_debian_backports; do
  [[ ! -z $repo_name ]] && echo "${!repo_name}" | tee -a /etc/apt/sources.list && echo '' >> /etc/apt/sources.list
done

echo "Updating and upgrading $hostname..."
apt update; apt full-upgrade -y

if [[ $debian_add_i386 == "1" ]]; then
  echo "Adding i386 arch..."
  dpkg --add-architecture i386
fi

if [[ ! -z $postinstall ]]; then
  echo "Downloading addational packages..."
  apt -y -d install $postinstall
fi
apt -y -d install console-setup-linux
if [[ $networkmanager == 1 ]]; then
  echo "Downloading Network Manager..."
  apt -y -d install network-manager
fi

if [[ $repos == "1" ]]; then
  apt -y install ca-certificates gnupg
  echo "Installing new keys and mirrors..."
  cd /root/certs

  if [[ ! -z $repo_debian_webmin ]]; then
    echo "Adding webmin..."
    apt-key add jcameron-key.asc
    echo "$repo_debian_webmin" | tee /etc/apt/sources.list.d/webmin.list
  fi

  if [[ ! -z $repo_debian_wine ]]; then
    echo "Adding wine..."
    apt-key add winehq.key
    echo "$repo_debian_wine" | tee /etc/apt/sources.list.d/wine.list
  fi

  apt update
  cd ..
fi

if [[ $kernel_var == "1" ]]; then
  echo "Installing linux kernel and its additions..."
  if [[ $backports_kernel == "1" ]]; then
    ADD_conf="-t $debian_distr-backports"
  fi
  case $debian_arch in
    i386) kernel_arch=686
    ;;
    *) kernel_arch=$debian_arch
    ;;
  esac
  apt -y $ADD_conf install linux-image-$kernel_arch linux-headers-$kernel_arch firmware-linux firmware-realtek firmware-atheros firmware-brcm80211 dkms
  apt -y -d $ADD_conf install r8168-dkms
fi

if [[ $graph == "1" ]]; then
  echo "Downloading graphics packages..."
  apt -y -d install xfce4 xfce4-goodies xfwm4-themes xserver-xorg-video-all xserver-xorg-input-all xserver-xorg
  [[ $networkmanager == "1" ]] && apt -y -d install network-manager-gnome
fi

if [[ $grub2 == "1" ]]; then
  DEBIAN_FRONTEND=noninteractive apt -y install grub2
  if [[ $flash_disk == "1" ]]; then
    apt -y remove os-prober
    apt -d -y install os-prober
  fi
fi

echo "Script has ended its work. Have a nice day!"

rm -rf /root/certs /root/pi_s{0,1}.sh
