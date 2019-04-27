#!/bin/bash
###############################################################
### linux_install script
###
### Copyright (C) 2018 Alexey Nasibulin
###
### By: Alexey Nasibulin (ktifhfl)
###
### License: GPL v3.0
###############################################################

case $(uname -m) in
  x86_64|amd64) debian_arch_default=amd64
  ;;
  arm64|aarch64|armv8l) debian_arch_default=arm64
  ;;
  i[3-6]86|x86) debian_arch_default=i386
  ;;
  *) debian_arch_default=$(uname -m)
  ;;
esac
echo "Arch avaliable: amd64,arm64,armel,armhf,i386,etc."
read_param "Enter arch for installation: " "$debian_arch_default" debian_arch text

read_param "Enter distribution: " "stretch" debian_distr text

echo "Now, You have to enter deb-* command for sources.list in debian."
echo "NOTE: \$debian_distr=$debian_distr. "
read_param "Enter main repo command: " "${repo_debian_main}" repo_debian_main text
echo ''
echo "If you don't want to add repo, just left it empty."
if [[ $debian_distr != "sid" ]]; then
  for repo_name in repo_debian_updates repo_debian_security repo_debian_backports; do
    read_param "Enter ${repo_name#repo_debian_*} repo command: " "${!repo_name}" $repo_name text_empty
  done
fi
echo ''
read_param "Do you want to add extrenal repositories (wine,webmin)? (Y/n): " "" repos yes_or_no
if [[ $repos == "1" ]]; then
  echo "If you don't want to install repo, just left it empty."
  echo "NOTE: The needed certificate will be installed automatically."
  read_param "Enter webmin repo command: " "$repo_debian_webmin" repo_debian_webmin text_empty
  read_param "Enter wine repo command: " "$repo_debian_wine" repo_debian_wine text_empty
fi

read_param "Enter addational packages for preinstallation: " "locales,sudo" preinstall text

read_param "Enter additional packages for postinstallation: " "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text

if [[ $debian_arch == amd64 ]]; then
  read_param "Do you want to add i386 arch repo? (Y/n): " '' debian_add_i386 yes_or_no
fi

read_param "Do you want to install NetworkManager? (Y/n): " '' networkmanager yes_or_no

read_param "Do you want to install kernel? (Y/n): " "" kernel_var yes_or_no
if [[ $kernel_var == '1' && $backports_repo_debian == '1' ]]; then
  read_param "Do you want to install backports-kernel? (N/y): " "" backports_kernel no_or_yes
  [[ $backports_kernel == 0 ]] && echo '[NOTE] Stable kernel will be installed.'
fi

# End of asking.

read_param "You're about to start installing debian $distr to $dir. Do you really want to continue? (Y/n): " "" enter yes_or_no
[[ $enter == 0 ]] && exit 0

source ./distr/$distr/${distr}_install.sh

echo "If you have any problems with drivers in this installed system, please, try to run command `update-initramfs -u -k all`."
echo ''
echo "Debian $distr was installed to $dir."
