#!/bin/bash

xbps-install -Sy grub-{x86_64,i386}-efi
grub-install --target=i386-efi --efi-directory=/boot --removable
grub-install --target=x86_64-efi --efi-directory=/boot --removable
grub-mkconfig -o /boot/grub/grub.cfg

rm -rf /root/{bios,uefi}.sh
