#!/bin/bash

set -e

#Use library
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-./lib/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ./lib/common/lib_connect.sh

if [[ -f ./private_parameters ]]; then
    li_type=private
else
    li_type=public
fi

ARCH="${ARCH:-x86_64}"
ALPINE_FILES="${ALPINE_FILES:-../../alpine/v3.14/releases/$ARCH/}"
BUILDS_DIR="${BUILDS_DIR:-../linux_install_builds}"
if [[ -d "$ALPINE_FILES" ]]; then
    msg_print note "Using local directory: $ALPINE_FILES"
else
    return_err "Needed directory not found!"
fi
[[ -d "$BUILDS_DIR" ]] || mkdir -p "$BUILDS_DIR"
[[ -e "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.pxe" ]] && rm -rf "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.pxe"
./bin/make_images/make_netboot.sh $ALPINE_FILES/netboot ./bin/make_images/linux_install_files "$ARCH" lts "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.pxe"
[[ -e "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.iso" ]] && rm -rf "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.iso"
./bin/make_images/make_iso.sh "$ALPINE_FILES/alpine-standard-3.14.0-$ARCH.iso" ./bin/make_images/linux_install_files "$ARCH" "$BUILDS_DIR/linux_install-$ARCH-$(cat ./version_install)-$li_type.iso"
msg_print note "Builds are located at $BUILDS_DIR."