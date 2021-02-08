print_param note "Distro-specific options:"
parse_arch $(uname -m)
read_param "Avaliable architectures are amd64,arm64,armel,armhf,i386,etc.\n" "Enter arch for installation" "$debian_arch" arch text

read_param "" "Enter distribution" "$debian_distr" debian_distr text
print_param note "Now, You have to enter deb-* command for sources.list in debian."
print_param note "Variable \$debian_distr is $debian_distr. You should leave it unchanged."
var_list[deb_repos_ma]="declare -A debian_repos"
if [[ $debian_distr == "sid" ]]; then
  for repo_name in updates security backports; do
    unset debian_repos[$repo_name]
  done
fi
print_param note "If you don't want to add repo, just leave it empty."
for repo_name in ${!debian_repos[@]}; do
  read_param "" "Enter $repo_name repo command" "${debian_repos[$repo_name]}" debian_repos[$repo_name] text_empty
  [[ -z ${debian_repos[$repo_name]} ]] && unset debian_repos[$repo_name]
done
read_param "" "Do you want to add repositories?" "" repos no_or_yes
while [[ $repos == 1 ]]; do
  read_param "" "Enter name of repo" "" repo_name text_empty
  [[ ! -z $repo_name ]] && read_param "" "Enter $repo_name repo command" "" debian_repos[$repo_name] text
  [[ -z $repo_name ]] && repos=0
done

read_param "" "Do you want to install kernel?" '' kernel yes_or_no
if [[ $kernel == "1" && $repo_debian_backports != "" ]]; then
  read_param "" "Do you want to install backports-kernel?" "" backports_kernel no_or_yes
  [[ $backports_kernel == "0" ]] && print_param note "Stable kernel will be installed."
fi
read_param "" "Do you want to install and enable NetworkManager?" '' networkmanager yes_or_no

[[ $debian_arch == amd64 ]] && read_param "" "Do you want to add i386 arch repo?" '' debian_add_i386 yes_or_no
read_param "" "Enter addational packages for preinstallation" "locales,rsync" preinstall text
read_param "" "Enter additional packages for postinstallation" "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text
