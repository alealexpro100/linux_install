#!/bin/bash

#Preconfiguration
set -e
cd /root/
echo 'Getting configuration...'
if [[ -z /root/configuration ]]; then
  echo '[ERROR] No configuration file! Exiting.'
  exit 1
else
  source /root/configuration
fi

if [[ $version == "glibc" ]]; then
  echo "Please uncomment locales for locale-gen in nano."
  sleep 3
  nano /etc/default/libc-locales
  xbps-reconfigure -f glibc-locales

  while [[ $language == '']]; do
    echo "Enter language for your system."
    echo "Example (en_US.UTF-8/$LANG)"
    read -e -p "LANG="  -i "$LANG" language
  done
  sed -e "1s/en_US.UTF-8/$LANG" >> /etc/locale.conf.new
  mv /etc/locale.conf{.new,}
fi

[[ $lightdm_autostart == 1 ]] && ln -s /etc/sv/lightdm /etc/runit/runsvdir/default/

rm -rf /root/configuration /root/pi_s2.sh
