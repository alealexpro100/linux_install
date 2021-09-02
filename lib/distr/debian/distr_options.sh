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
    # shellcheck disable=SC2046
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE" "xorg" graphics_type menu_var $(echo -e "xorg\nwayland" | gen_menu)
    # shellcheck disable=SC2046
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE" "DE" desktop_type menu_var $(echo -e "DE\nM" | gen_menu)
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        # shellcheck disable=SC2046
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var $(echo -e "plasma\nxfce4\ncinnanmon\ngnome" | gen_menu)
      else
        # shellcheck disable=SC2046
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var $(echo -e "plasma\ngnome" | gen_menu)
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "task-kde-desktop" desktop_packages text_empty
    fi
  fi
fi

# shellcheck disable=SC2046
read_param "" "$M_ARCH_ENTER" "$debian_arch" arch menu_var $(echo -e "amd64\ni386\narm64\narmel\narmhf\nmips\nmips64el\nmipsel\nppc64el\ns390x" | gen_menu)

read_param "" "$M_DISTR_VER" "$version_debian" version_debian text
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
add_var "declare -gx" "debian_repos[main]" "deb https://deb.debian.org/debian $version_debian main non-free contrib"
add_var "declare -gx" "debian_repos_order[0]" "main"
if [[ $version_debian != "sid" ]]; then
    add_var "declare -gx" "debian_repos[main]" "deb $debian_mirror $version_debian main non-free contrib"
    add_var "declare -gx" "debian_repos_order[0]" "main"
    add_var "declare -gx" "debian_repos[updates]" "deb $debian_mirror $version_debian-updates main non-free contrib"
    add_var "declare -gx" "debian_repos_order[1]" "updates"
    add_var "declare -gx" "debian_repos[backports]" "deb $debian_mirror $version_debian-backports main non-free contrib"
    add_var "declare -gx" "debian_repos_order[2]" "backports"
    if [[ $version_debian == "bullseye" || $version_debian == "testing" ]]; then
      add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $version_debian-security main non-free contrib"
    else
      add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $version_debian/updates main non-free contrib"
    fi
    add_var "declare -gx" "debian_repos_order[3]" "security"
fi
[[ -n ${debian_repos_add[*]} ]] && print_param note "$M_DEB_REPO_1"
for repo_name in "${!debian_repos_add[@]}"; do
  read_param "" "$M_DEB_REPO_DIALOG $repo_name" "${debian_repos_add[$repo_name]}" debian_repos[$repo_name] text_empty
  [[ -n ${debian_repos[$repo_name]} ]] && add_var "declare -gx" "debian_repos_order[${#debian_repos_order[@]}]" "$repo_name"
done
read_param "" "$M_DEB_REPO_ADD" "" repos no_or_yes
while [[ $repos == 1 ]]; do
  print_param note "$M_DEB_NOTE_1"
  print_param note "$M_DEB_NOTE_2 $version_debian."
  read_param "" "$M_DEB_REPO_NAME" "" repo_name text_empty
  [[ -n $repo_name ]] && read_param "" "$M_DEB_REPO_DIALOG $repo_name" "${debian_repos_add[$repo_name]:-"deb https://example.com/debian $version_debian main"}" "debian_repos[$repo_name]" text
  [[ -n ${debian_repos[$repo_name]} ]] && add_var "declare -gx" "debian_repos_order[${#debian_repos_order[@]}]" "$repo_name"
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
