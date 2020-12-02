msg_print note "Distro-specific options:"
parse_arch $(uname -m)
msg_print note "Avaliable architectures: amd64,arm64,armel,armhf,i386,etc."
read_param "Enter arch for installation: " "$debian_arch" arch text

read_param "Enter distribution: " "$debian_distr" debian_distr text
msg_print note "Now, You have to enter deb-* command for sources.list in debian."
msg_print note "Variable \$debian_distr is $debian_distr. You should leave it unchanged."
var_list[deb_repos_ma]="declare -A debian_repos"
if [[ $debian_distr == "sid" ]]; then
  for repo_name in updates security backports; do
    unset debian_repos[$repo_name]
  done
fi
msg_print note "If you don't want to add repo, just leave it empty."
for repo_name in ${!debian_repos[@]}; do
  read_param "Enter $repo_name repo command: " "${debian_repos[$repo_name]}" debian_repos[$repo_name] text_empty
  [[ -z ${debian_repos[$repo_name]} ]] && unset debian_repos[$repo_name]
done
read_param "Do you want to add repositories? (N/y): " "" repos no_or_yes
while [[ $repos == 1 ]]; do
  read_param "Enter name of repo: " "" repo_name text_empty
  [[ ! -z $repo_name ]] && read_param "Enter $repo_name repo command: " "" debian_repos[$repo_name] text
  [[ -z $repo_name ]] && repos=0
done

read_param "Do you want to install kernel? (Y/n): " '' kernel yes_or_no
if [[ $kernel == "1" && $repo_debian_backports != "" ]]; then
  read_param "Do you want to install backports-kernel? (N/y): " "" backports_kernel no_or_yes
  [[ $backports_kernel == "0" ]] && msg_print note "Stable kernel will be installed."
fi
read_param "Do you want to install and enable NetworkManager? (Y/n): " '' networkmanager yes_or_no
read_param "Do you want to install and enable pulseaudio? (Y/n): " '' pulseaudio yes_or_no
read_param "Do you want to install and enable bluetooth? (Y/n): " '' bluetooth yes_or_no
read_param "Do you want to add printers support? (Y/n): " '' printers yes_or_no

if [[ $bootloader == "1" ]]; then
  msg_print note "Choose grub2. Others are not supported yet."
  if [[ $bootloader_type = uefi ]]; then
    msg_print note "Avaliable bootloaders: grub2, syslinux, systemd, refind."
    read_param "Enter name of bootloader: " "grub2" bootloader_name text
  else
    msg_print note "Avaliable bootloaders: grub2, syslinux."
    read_param "Enter name of bootloader: " "grub2" bootloader_name text
  fi
fi

if [[ $graphics == "1" ]]; then
  msg_print note "Wayland is not supported now. Do NOT choose it."
  while ! [[ $graphics_type == "xorg" || $graphics_type == "wayland" ]]; do
    read_param "Enter type of graphics (xorg/wayland): " "xorg" graphics_type text
  done
  msg_print note "DE - Desktop environment, WM - window manager, M - manual."
  while ! [[ $desktop_type == "DE" || $desktop_type == "WM" || $desktop_type == "M" ]]; do
    read_param "Enter desktop type (DE/WM/M): " "DE" desktop_type text
  done
  if [[ $desktop_type != "M" ]]; then
    if [[ $graphics_type == "xorg" ]]; then
      if [[ $desktop_type == "DE" ]]; then
        msg_print note "Avaliable DEs: plasma, xfce4, cinnamon, gnome."
        read_param "Enter DE name: " "xfce4" desktop_de text
      else
        msg_print note "Avaliable WMs: icewm, fvwm, jvm."
        read_param "Do you want to install addational software: " "icewm" desktop_wm text
      fi
    else
      return_err "Wayland is not supported now!"
    fi
    msg_print note "Addational software."
    #read_param "Do you want to install firefox? (Y/n): " '' firefox_soft yes_or_no
    #read_param "Do you want to install chromium? (Y/n): " '' chromium_soft yes_or_no
    #read_param "Do you want to install office software? (Y/n): " '' office_soft yes_or_no
    #read_param "Do you want to install administration software? (Y/n): " '' admin_soft yes_or_no
  else
    read_param "Enter desktop package(s) or nothing: " "xfce4 xfce4-goodies" desktop_packages text_empty
  fi
  [[ $dm_install == "0" ]] && msg_print note "Default DM will be disabled."
fi

read_param "Enter addational packages for preinstallation: " "locales,rsync" preinstall text
read_param "Enter additional packages for postinstallation: " "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text
[[ $debian_arch == amd64 ]] && read_param "Do you want to add i386 arch repo? (Y/n): " '' debian_add_i386 yes_or_no
