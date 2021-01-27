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

[[ $debian_arch == amd64 ]] && read_param "Do you want to add i386 arch repo? (Y/n): " '' debian_add_i386 yes_or_no
read_param "Enter addational packages for preinstallation: " "locales,rsync" preinstall text
read_param "Enter additional packages for postinstallation: " "usbutils pciutils dosfstools software-properties-common bash-completion" postinstall text
