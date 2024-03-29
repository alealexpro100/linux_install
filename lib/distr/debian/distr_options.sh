#!/bin/bash

if [[ $LIVE_MODE == "0" ]]; then
  read_param "" "$M_ARCH_ENTER" "$debian_arch" arch menu_var "$(gen_menu < <(echo -e "amd64\ni386\narm64\narmel\narmhf\nmips\nmips64el\nmipsel\nppc64el\ns390x"))"
else
  add_var "declare -gx" arch "$debian_arch"
fi

deb_distros="oldoldstable\noldstable\nstable\ntesting
stretch\nbuster\nbullseye\nbookworm\nsid"
read_param "" "$M_DISTR_VER" "$version_debian" version_debian menu_var "$(gen_menu < <(echo -e "$deb_distros"))"
unset deb_distros

distr_debian=""
case $version_debian in
  oldoldstable) distr_debian=stretch;;
  oldstable) distr_debian=buster;;
  stable) distr_debian=bullseye;;
  testing) distr_debian=bookworm;;
  *) distr_debian=$version_debian;;
esac

#Add all known repos.
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
components=""
case $distr_debian in
  buzz|rex|bo|hamm|slink|potato|woody|sarge|etch|lenny|squeeze|wheezy|jessie)
    print_param warn "NOT TESTED!"
    if [[ $distr_debian == "buzz" || $distr_debian == "rex" ]]; then
      components="main contrib"
    else
      components="main non-free contrib"
    fi
    add_var "declare -gx" "debian_repos[main]" "deb $debian_archive_mirror $distr_debian $components"
    add_var "declare -gx" "debian_repos_order[0]" "main"
  ;;
  stretch|buster|bullseye|bookworm)
    if [[ $distr_debian == "bookworm" ]]; then
      components="main non-free contrib non-free-firmware"
    else
      components="main non-free contrib"
    fi
    add_var "declare -gx" "debian_repos[main]" "deb $debian_mirror $distr_debian $components"
    add_var "declare -gx" "debian_repos_order[0]" "main"
    add_var "declare -gx" "debian_repos[updates]" "deb $debian_mirror $distr_debian-updates $components"
    add_var "declare -gx" "debian_repos_order[1]" "updates"
    add_var "declare -gx" "debian_repos[backports]" "deb $debian_mirror $distr_debian-backports $components"
    add_var "declare -gx" "debian_repos_order[2]" "backports"
    if [[ $distr_debian == "stretch" || $distr_debian == "buster" ]]; then
      add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $distr_debian/updates $components"
    else
      add_var "declare -gx" "debian_repos[security]" "deb $debian_mirror_security $distr_debian-security $components"
    fi
    add_var "declare -gx" "debian_repos_order[3]" "security"
  ;;
  experimental|sid)
    components="main non-free contrib non-free-firmware"
    add_var "declare -gx" "debian_repos[main]" "deb $debian_mirror $distr_debian $components"
    add_var "declare -gx" "debian_repos_order[0]" "main"
  ;;
  *) return_err "Incorrect paramater distr_debian=$distr_debian! Mistake?"
esac
unset components
for repo_name in "${!debian_repos_add[@]}"; do
  add_var "declare -gx" "debian_repos[$repo_name]" "$(echo -e "${debian_repos_add[$repo_name]}" | sed "s/\$version_debian/$distr_debian/g")"
  add_var "declare -gx" "debian_repos_order[${#debian_repos_order[@]}]" "$repo_name"
done

until [[ $repos == "0" ]]; do
  vars_list="$M_LIST_END_OPTION"
  for repo_name in "${debian_repos_order[@]}"; do
    vars_list+="\n$repo_name | ${debian_repos[$repo_name]}"
  done
  NO_VAR=1 NO_HISTORY=1 read_param "$M_DEB_REPO_TEXT\n" "$M_LIST_DIALOG" "0" repos menu "$(gen_menu < <(echo -e "$vars_list"))"
  if [[ $repos != "0" ]]; then
    curr_num=$((${repos#0}-1))
    repo_name="${debian_repos_order[curr_num]}"
    read_param "$M_DEB_REPO_1\n" "$M_DEB_REPO_DIALOG $repo_name" "${debian_repos[$repo_name]}" "debian_repos[$repo_name]" text_empty
    [[ -n "${debian_repos[$repo_name]}" ]] || add_var "unset" "debian_repos[$curr_num]"
  fi
  unset repo_name curr_num vars_list
done
unset repos

if [[ $kernel == "1" ]]; then
  read_param "" "$M_KERNEL_TYPE" "$([[ $(detect_vm) || "$kernel_type" == "virtual" ]] && echo 1 || echo 0)" kernel_type menu_var "$(gen_menu < <(echo -e "vanilla\nvirtual"))"
  [[ -n ${debian_repos[backports]} ]] && read_param "" "$M_DEB_BACKPORTS_KERNEL" "" backports_kernel no_or_yes
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
  read_param "" "$M_BLUETOOTH" '' bluetooth yes_or_no
  read_param "" "$M_PRINTERS" '' printers yes_or_no
fi
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_GRAPH" '' graphics yes_or_no
  if [[ $graphics == "1" ]]; then
    read_param "$M_GRAPH_TYPE_M" "$M_GRAPH_TYPE" "xorg" graphics_type menu_var "$(gen_menu < <(echo -e "xorg\nwayland"))"
    read_param "$M_DESKTOP_TYPE_M" "$M_DESKTOP_TYPE" "DE" desktop_type menu_var "$(gen_menu < <(echo -e "DE\nM"))"
    if [[ $desktop_type != "M" ]]; then
      if [[ $graphics_type == "xorg" ]]; then
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "$(gen_menu < <(echo -e "plasma\nxfce4\ncinnanmon\ngnome"))"
      else
        read_param "" "$M_DESKTOP_DE" "plasma" desktop_de menu_var "$(gen_menu < <(echo -e "plasma\ngnome"))"
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
