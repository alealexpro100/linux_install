#!/bin/bash

xbps-install -Sy grub-bios
grub-install --target=i386-pc --debug --force $grub2_bios_place
grub-mkconfig -o /boot/grub/grub.cfg

rm -rf /root/{bios,uefi}.sh
