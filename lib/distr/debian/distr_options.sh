#!/bin/bash

gen_menu < <(echo -e "amd64\ni386\narm64\narmel\narmhf\nmips\nmips64el\nmipsel\nppc64el\ns390x")
read_param "" "$M_ARCH_ENTER" "$debian_arch" arch menu_var "${tmp_gen_menu[@]}"

read_param "" "$M_DISTR_VER" "$version_debian" version_debian text

#Add all known repos.
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
add_var "declare -gx" "debian_repos[main]" "deb $debian_mirror $version_debian main non-free contrib"
add_var "declare -gx" "debian_repos_order[0]" "main"
if [[ $version_debian != "sid" ]]; then
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
for repo_name in "${!debian_repos_add[@]}"; do
  add_var "declare -gx" "debian_repos[$repo_name]" "$(echo -e "${debian_repos_add[$repo_name]}" | sed "s/\$version_debian/$version_debian/g")"
  add_var "declare -gx" "debian_repos_order[${#debian_repos_order[@]}]" "$repo_name"
done

until [[ $repos == "0" ]]; do
  vars_list="$M_LIST_END_OPTION"
  for repo_name in "${debian_repos_order[@]}"; do
    vars_list+="\n$repo_name | ${debian_repos[$repo_name]}"
  done
  gen_menu < <(echo -e "$vars_list")
  read_param "$M_DEB_REPO_TEXT\n" "$M_LIST_DIALOG" "0" repos menu "${tmp_gen_menu[@]}"
  if [[ $repos != "0" ]]; then
    curr_num=$((${repos#0}-1))
    repo_name="${debian_repos_order[curr_num]}"
    read_param "$M_DEB_REPO_1\n" "$M_DEB_REPO_DIALOG $repo_name" "${debian_repos[$repo_name]}" "debian_repos[$repo_name]" text_empty
    [[ -n "${debian_repos[$repo_name]}" ]] || add_var "unset" "debian_repos[$curr_num]"
  fi
  unset repo_name curr_num vars_list
done

if [[ $kernel == "1" ]]; then
  if detect_vm; then
    gen_menu < <(echo -e "virtual\nvanilla")
  else
    gen_menu < <(echo -e "vanilla\nvirtual")
  fi
  read_param "" "$M_KERNEL_TYPE" '' kernel_type menu_var "${tmp_gen_menu[@]}"
  [[ -n ${debian_repos[backports]} ]] && read_param "" "$M_DEB_BACKPORTS_KERNEL" "" backports_kernel no_or_yes
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    gen_menu < <(echo -e "xorg\nwayland")
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE" "xorg" graphics_type menu_var "${tmp_gen_menu[@]}"
    gen_menu < <(echo -e "DE\nM")
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE" "DE" desktop_type menu_var "${tmp_gen_menu[@]}"
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        gen_menu < <(echo -e "plasma\nxfce4\ncinnanmon\ngnome")
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "${tmp_gen_menu[@]}"
      else
        gen_menu < <(echo -e "plasma\ngnome")
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "${tmp_gen_menu[@]}"
      fi
    else
      read_param "" "$M_DESKTOP_MANUAL_PKGS" "task-kde-desktop" desktop_packages text_empty
    fi
  fi
fi

read_param "" "$M_DEB_NO_RECOMMENDS" '' debian_no_recommends no_or_yes
[[ $debian_arch == amd64 ]] && read_param "" "$M_MULTILIB" '' debian_add_i386 yes_or_no
add_var "declare -gx" "preinstall" "locales"
read_param "" "$M_PACK" "usbutils pciutils dosfstools software-properties-common screen htop rsync bash-completion" postinstall text_empty
