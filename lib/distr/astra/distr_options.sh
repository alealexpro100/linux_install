#!/bin/bash

gen_menu < <(echo -e "amd64\ni386\narm64\narmel\narmhf\nmips\nmips64el\nmipsel\nppc64el\ns390x")
read_param "" "$M_ARCH_ENTER" "$debian_arch" arch menu_var "${tmp_gen_menu[@]}"

read_param "" "$M_DISTR_VER" "$version_astra" version_debian text

#Add all known repos.
add_var "declare -gA" "debian_repos"
add_var "declare -ga" "debian_repos_order"
if [[ $astra_mirror =~ https* ]]; then
  msg_print warning "Detected https mirror! Will use http for install."
  astra_mirror="${astra_mirror/https\:/http\:}"
fi
add_var "declare -gx" "debian_repos[main]" "deb $astra_mirror $version_debian main non-free contrib"
add_var "declare -gx" "debian_repos_order[0]" "main"

if [[ $kernel == "1" ]]; then
  if detect_vm; then
    gen_menu < <(echo -e "virtual\nvanilla")
  else
    gen_menu < <(echo -e "vanilla\nvirtual")
  fi
  read_param "" "$M_KERNEL_TYPE" '' kernel_type menu_var "${tmp_gen_menu[@]}"
fi

if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_SSH" '' ssh yes_or_no
fi

read_param "" "$M_DEB_NO_RECOMMENDS" '' debian_no_recommends no_or_yes
[[ $debian_arch == amd64 ]] && read_param "" "$M_MULTILIB" '' debian_add_i386 yes_or_no
add_var "declare -gx" "preinstall" "locales"
read_param "" "$M_PACK" "usbutils pciutils dosfstools software-properties-common screen htop rsync bash-completion" postinstall text_empty
