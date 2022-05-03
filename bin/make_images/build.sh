#!/bin/bash

set -e

#Use library
export ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-./lib/alexpro100_lib.sh}"
# shellcheck disable=SC1091
source ./lib/common/lib_connect.sh

LI_TYPE="${LI_TYPE:-private}" LI_DEBUG="${LI_DEBUG:-0}"
LI_VERSION="$(cat ./version_install)"
[[ "$LI_DEBUG" == "1" ]] && LI_VERSION="${LI_VERSION}-dbg"
ARCH="${ARCH:-x86_64}"
ALPINE_VERSION="3.14" ALPINE_REVISION="6" ALPINE_NETBOOT_VERSION="lts"
BUILDS_DIR="${BUILDS_DIR:-../linux_install_builds}"
ALPINE_ISO="${ALPINE_ISO:-../../alpine/v$ALPINE_VERSION/releases/$ARCH/alpine-standard-$ALPINE_VERSION.$ALPINE_REVISION-$ARCH.iso}"
ALPINE_NETBOOT="${ALPINE_NETBOOT:-../../alpine/v$ALPINE_VERSION/releases/$ARCH/netboot-$ALPINE_VERSION.$ALPINE_REVISION}"
LI_ISO="$BUILDS_DIR/linux_install-$ARCH-$LI_VERSION-$LI_TYPE.iso"
LI_NETBOOT="$BUILDS_DIR/linux_install-$ARCH-$LI_VERSION-$LI_TYPE.pxe"
LI_BUILD_ISO="${LI_BUILD_ISO:-1}" LI_BUILD_NETBOOT="${LI_BUILD_NETBOOT:-1}"
[[ "$LI_BUILD_ISO" == "1" && -f "$ALPINE_ISO" ]] || return_err "Needed file for ISO not found!"
[[ "$LI_BUILD_NETBOOT" == "1" && -d "$ALPINE_NETBOOT" ]] || return_err "Needed directory for NETBOOT not found!"

function make_bootable_iso() (
    local iso_location
    iso_location="$(realpath "$2")"
    cd -- "$1" || return_err "No directory $1!"
    mkisofs -o "$iso_location"  -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
      -eltorito-alt-boot -eltorito-platform 0xEF -eltorito-boot boot/grub/efi.img -no-emul-boot -lJR .; 
)

function prepare_initfs() {
    arccat gz "$1" | unpack_cpio "${make_build:?}/initfs"
    mv "$make_build/initfs/init" "$make_build/initfs/init_orig"
    cp "$build_files/init" "$make_build/initfs/init"
    pack_initfs_cpio "$make_build/initfs" | zstd -T12 -10 > "$2"
}

[[ "$LI_DEBUG" == "1" ]] && msg_print warning "Building DEBUG version..."

[[ -d "$BUILDS_DIR" ]] || mkdir -p "$BUILDS_DIR"
build_files="./bin/make_images/linux_install_files"
create_tmp_dir make_build
#Prepare rootfs
mkdir "$make_build/rootfs" "$make_build/custom" 
cp -r "$build_files/custom/." "$make_build/custom"
mount -t tmpfs tmpfs "$make_build/rootfs"
cp "./auto_configs/linux_install_$ARCH.sh" "$make_build/config.sh"
CUSTOM_DIR="$make_build/custom" default_dir="$make_build/rootfs" "./install_sys.sh" "$make_build/config.sh"
[[ "$LI_DEBUG" == "1" ]] && sed -i '6s/=0/=1/' "$make_build/rootfs/root/installer.sh"
cp -Rf . "$make_build/rootfs/root/linux_install"
rm -rf "$make_build/rootfs/root/linux_install/.git" \
    "$make_build/rootfs/root/linux_install/_config.yml" \
    "$make_build/rootfs/root/linux_install/bin/make_images"
if [[ "$LI_TYPE" == "public" ]]; then
    rm -rf "$make_build/rootfs/root/linux_install/private_parameters" \
    "$make_build/rootfs/root/linux_install/custom/custom_script.sh" \
    "$make_build/rootfs/root/linux_install/custom/rootfs"
fi
squashfs_rootfs_pack "$make_build/rootfs" "$make_build/rootfs.img" xz
umount "$make_build/rootfs"

if [[ $LI_BUILD_ISO == "1" ]]; then
    msg_print note "Building ISO..."
    [[ -e "$LI_ISO" ]] && rm -rf "$LI_ISO"
    mkdir "$make_build/orig_iso" "$make_build/final_iso" "$make_build/initfs"
    mount "$ALPINE_ISO" "$make_build/orig_iso"
    cp -a "$make_build/orig_iso/." "$make_build/final_iso"
    umount "$make_build/orig_iso"
    prepare_initfs "$(find "$make_build/final_iso/boot" -name "*initramfs-*" | head -n 1)" "$(find "$make_build/final_iso/boot" -name "*initramfs-*" | head -n 1)"
    cp "$make_build/rootfs.img" "$make_build/final_iso/apks/rootfs.img"
    sed -ie 's/quiet/quiet rootfs_net=rootfs.img/' "$make_build/final_iso/boot/syslinux/syslinux.cfg"
    sed -ie 's/quiet/quiet rootfs_net=rootfs.img/' "$make_build/final_iso/boot/grub/grub.cfg"
    make_bootable_iso "$make_build/final_iso" "$LI_ISO"
    rm -rf "$make_build/orig_iso" "$make_build/final_iso" "$make_build/initfs"
fi

if [[ $LI_BUILD_NETBOOT == "1" ]]; then
    msg_print note "Building NETBOOT..."
    mkdir "$make_build/final_netboot" "$make_build/initfs"
    cp -a "$ALPINE_NETBOOT"/{vmlinuz,modloop}-"$ALPINE_NETBOOT_VERSION" "$make_build/final_netboot"
    prepare_initfs "$ALPINE_NETBOOT/initramfs-$ALPINE_NETBOOT_VERSION" "$make_build/final_netboot/initfs.img"
    cp "$make_build/rootfs.img" "$make_build/final_netboot/rootfs.img"
    cp -a "$make_build/final_netboot/." "$LI_NETBOOT/"
fi

rm -rf "$make_build"

msg_print note "Builds are located at $BUILDS_DIR."