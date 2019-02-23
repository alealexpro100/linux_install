#!/bin/bash

grub-install --target=i386-pc --debug --force $grub2_bios_place
update-grub

rm -rf /root/{bios,uefi}.sh
