#!/bin/bash

apt -y install grub-efi-amd64-bin grub-efi-ia32-bin
grub-install --target=i386-efi --efi-directory=/boot --removable
grub-install --target=x86_64-efi --efi-directory=/boot --removable
update-grub

rm -rf /root/{bios,uefi}.sh
