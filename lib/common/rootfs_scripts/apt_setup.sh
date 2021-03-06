
#Apt config
msg_print note "Apt setup..."
declare -gx DEBIAN_FRONTEND=noninteractive
apt_install="apt -y install"

[[ -f /etc/apt/sources.list ]] && rm -rf /etc/apt/sources.list
for repo_name in main updates backports security; do
  [[ -n ${debian_repos[$repo_name]} ]] && echo -e "#$repo_name\n${debian_repos[$repo_name]}\n" >> /etc/apt/sources.list
done
[[ $debian_add_i386 == "1" ]] && dpkg --add-architecture i386
apt update
$apt_install ca-certificates gnupg
for repo_name in ${!debian_repos[@]}; do
  if [[ $repo_name != "main" && $repo_name != "updates" && $repo_name != "backports" && $repo_name != "security" ]]; then
    echo -e "\n#$repo_name\n${debian_repos[$repo_name]}\n" >> /etc/apt/sources.list
    [[ -f "/root/certs/$repo_name.key" ]] && apt-key add "/root/certs/$repo_name.key"
  fi
done
apt update

msg_print note "Apt is ready."