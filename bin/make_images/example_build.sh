#!/bin/bash

ALPINE_FILES=../../alpine/v3.14/releases/x86_64/
mkdir -p ../builds
./bin/make_images/make_netboot.sh $ALPINE_FILES/netboot ./bin/make_images/linux_install_files x86_64 lts ../builds/pxe_lts
./bin/make_images/make_iso.sh $ALPINE_FILES/alpine-standard-3.14.0-x86_64.iso ./bin/make_images/linux_install_files x86_64 "../builds/linux_install-standart-x86_64-$(cat ./version_install)-private.iso"
#qemu-system-x86_64 -enable-kvm -m 512M -cdrom "../builds/linux_install-standart-x86_64-$(cat ./version_install)-private.iso"
