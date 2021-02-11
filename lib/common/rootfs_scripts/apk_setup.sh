
#Apk config
msg_print note "Apk setup..."
apk_install="apk add"

[[ -f /etc/apk/repositories ]] && rm -rf /etc/apk/repositories
echo -e "$mirror_alpine/$version_alpine/main\n$mirror_alpine/$version_alpine/community" >> /etc/apk/repositories
apk update

to_install="$postinstall" to_enable=''
[[ -n "$to_install" ]] && $apk_install $to_install

msg_print note "Apk is ready."