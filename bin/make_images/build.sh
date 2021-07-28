#!/bin/bash

if [[ -f ./private_parameters ]]; then
    li_type=private
else
    li_type=public
fi

li_ARCH="x86_64"
li_ALPINE_FILES="../../alpine/v3.14/releases/$li_ARCH/"
li_BUILDS_DIR="../linux_install_builds"
[[ -d "$li_BUILDS_DIR" ]] || mkdir -p "$li_BUILDS_DIR"
[[ -e "#BUILDS_DIR/linux_install-$li_type.pxe" ]] && rm -rf "$li_BUILDS_DIR/linux_install-$li_type.pxe"
./bin/make_images/make_netboot.sh $li_ALPINE_FILES/netboot ./bin/make_images/linux_install_files "$li_ARCH" lts "$li_BUILDS_DIR/linux_install-$li_type.pxe"
[[ -e "$li_BUILDS_DIR/linux_install-$li_ARCH-$(cat ./version_install)-$li_type.iso" ]] && rm -rf "$li_BUILDS_DIR/linux_install-$li_ARCH-$(cat ./version_install)-$li_type.iso"
./bin/make_images/make_iso.sh "$li_ALPINE_FILES/alpine-standard-3.14.0-$li_ARCH.iso" ./bin/make_images/linux_install_files "$li_ARCH" "$li_BUILDS_DIR/linux_install-$li_ARCH-$(cat ./version_install)-$li_type.iso"
echo "Builds are located at $li_BUILDS_DIR."