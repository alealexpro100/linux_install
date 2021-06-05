#!/bin/bash

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE (xorg/wayland)" "xorg" graphics_type text_check xorg,wayland
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE (DE/M)" "DE" desktop_type text_check DE,M
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        read_param "$M_DESKTOP_DE_M: plasma, xfce4, cinnamon, gnome.\n" "$M_DESKTOP_DE" "plasma" desktop_de text_check plasma,xfce4,cinnanmon,gnome
      else
        read_param "$M_DESKTOP_DE_M: plasma, gnome.\n" "$M_DESKTOP_DE" "plasma" desktop_de text_check plasma,gnome
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "task-kde-desktop" desktop_packages text_empty
    fi
  fi
fi

read_param "$M_ARCH_AVAL amd64,arm64,armel,armhf,i386,etc.\n" "$M_ARCH_ENTER" "$debian_arch" arch text

read_param "" "$M_DISTR_VER" "$version_debian" version_debian text
print_param note "$M_DEB_NOTE_1"
print_param note "$M_DEB_NOTE_2 $version_debian."
add_var "declare -gA" "debian_repos"
if [[ $version_debian == "sid" ]]; then
  for repo_name in updates security backports; do
    unset "debian_repos[$repo_name]"
  done
fi
print_param note "$M_DEB_REPO_1"
for repo_name in "${!debian_repos[@]}"; do
  read_param "" "$M_DEB_REPO_DIALOG $repo_name" "${debian_repos[$repo_name]}" debian_repos[$repo_name] text_empty
  [[ -z ${debian_repos[$repo_name]} ]] && unset debian_repos[$repo_name]
done
read_param "" "$M_DEB_REPO_ADD" "" repos no_or_yes
while [[ $repos == 1 ]]; do
  read_param "" "$M_DEB_REPO_NAME" "" repo_name text_empty
  [[ -n $repo_name ]] && read_param "" "$M_DEB_REPO_DIALOG $repo_name" "deb https://example.com/debian $version_debian main" "debian_repos[$repo_name]" text
  read_param "" "$M_DEB_REPO_ADD" "" repos no_or_yes
  [[ -z $repo_name ]] && repos=0
done

if [[ $kernel == "1" && -n ${debian_repos[backports]} ]]; then
  read_param "" "$M_DEB_BACKPORTS_KERNEL" "" backports_kernel no_or_yes
  [[ $backports_kernel == "0" ]] && print_param note "$M_DEB_STABLE_KERNEL"
fi

[[ $debian_arch == amd64 ]] && read_param "" "$M_MULTILIB" '' debian_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "locales,rsync" preinstall text
read_param "" "$M_PACK_POST" "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text_empty
