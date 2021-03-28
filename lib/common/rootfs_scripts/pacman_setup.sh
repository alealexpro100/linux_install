 
#Pacman setup.
msg_print note "Pacman setup..."
pacman_install="pacman -Suy --needed --noconfirm"

sed -i "s/#Color/Color/" /etc/pacman.conf
[[ $arch_add_i386 == "1" ]] && sed -ie '$!N;s|\#\[multilib\]\n\#Include|\[multilib\]\nInclude|;P;D' /etc/pacman.conf #>_<
mv /etc/pacman.d/mirrorlist{,.pacnew}
mv /etc/pacman.d/mirrorlist{.used,}

msg_print note "Pacman is ready."