
read_param "" "$M_ADD_SOFT" '' add_soft yes_or_no
if [[ $add_soft == "1" ]]; then
  read_param "" "$M_NETWORKMANAGER" '' networkmanager yes_or_no
  read_param "" "$M_PULSEAUDIO" '' pulseaudio yes_or_no
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

read_param "" "$M_KERNEL" '' kernel yes_or_no
if [[ $kernel == "1" && $repo_debian_backports != "" ]]; then
  read_param "" "$M_DEB_BACKPORTS_KERNEL" "" backports_kernel no_or_yes
  [[ $backports_kernel == "0" ]] && print_param note "$M_DEB_STABLE_KERNEL"
fi

[[ $debian_arch == amd64 ]] && read_param "" "$M_MULTILIB" '' debian_add_i386 yes_or_no
read_param "" "$M_PACK_PRE" "locales,rsync" preinstall text
read_param "" "$M_PACK_POST" "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text_empty
