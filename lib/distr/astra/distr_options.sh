#!/bin/bash

add_var "declare -gx" arch "$debian_arch"
# We disable gpg check, exclude 'usr-is-merged' dependency and set component to install dependency 'libparsec-base3'
add_var "declare -gx" "deb_add_option" "--no-check-gpg --exclude=usr-is-merged --components=main,contrib,non-free"

read_param "" "$M_DISTR_VER" "$version_astra" version_astra text
# There are now scripts for version of astra, so we use stable as fallback.
add_var "declare -gx" version_debian "stable"

#Add all known repos.
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
# Yes, there are also SE edition with additional repos, but there are license problems.
# To use it please build your own profile.
add_var "declare -gx" "debian_repos[main]" "deb $astra_mirror $version_astra main non-free contrib"
add_var "declare -gx" "debian_repos_order[0]" "main"

if [[ $kernel == "1" ]]; then
  read_param "" "$M_KERNEL_TYPE" "$([[ $(detect_vm) || "$kernel_type" == "virtual" ]] && echo 1 || echo 0)" kernel_type menu_var "$(gen_menu < <(echo -e "vanilla\nvirtual"))"
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
  read_param "" "$M_GRAPH" '' graphics yes_or_no
fi

read_param "" "$M_DEB_NO_RECOMMENDS" '' debian_no_recommends no_or_yes
add_var "declare -gx" "preinstall" "sudo,locales"
read_param "" "$M_PACK" "usbutils pciutils dosfstools software-properties-common screen htop rsync bash-completion" postinstall text_empty
