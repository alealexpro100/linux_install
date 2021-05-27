#!/bin/bash

ALPINE_FILES=./alpine/v3.13/releases/x86_64/
./bin/make_images/make_iso.sh $ALPINE_FILES/alpine-standard-3.13.5-x86_64.iso ./bin/make_images/linux_install_files x86_64 ./linux_install-standart-x86_64-public.iso;
qemu-system-x86_64 -enable-kvm -m 2G -cdrom ./linux_install-standart-x86_64-public.iso
./bin/make_images/make_netboot.sh $ALPINE_FILES/netboot ./bin/make_images/linux_install_files x86_64 lts ./lts