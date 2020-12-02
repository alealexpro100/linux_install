
#Base changes.
msg_print note "Making base changes..."

function base_setup() {
  msg_print note "Setting up hostname and configuring user..."
  echo $hostname > /etc/hostname
  echo "root:$passwd" | chpasswd
  useradd -m -g users -G $user_groups -s $user_shell $user_name
  echo  "$user_name:$passwd" | chpasswd
}

function locale_setup() {
  msg_print note "Setting up locales..."
  sed -i "s/#en_US.UTF-8/en_US.UTF-8;s/#$LANG/$LANG/" /etc/locale.gen
  echo "LANG=$LANG" >> /etc/default/locale
  locale-gen
}

case $distr in
  archlinux)
  user_groups="users,video,input,wheel"
  base_setup; locale_setup
  ;;
  debian)
  user_groups="users,video,input,sudo"
  base_setup; locale_setup
  ;;
  *) msg_print warning "Non-standart distro $distro used. Skipping locale setup."
  user_groups="users,video,input"; base_setup;
  ;;
esac

msg_print note "Base configured succesfully."