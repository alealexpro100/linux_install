#!/bin/bash

MIRROR_DIR="/mnt/mirror"
WORK_DIR="/mnt/mirror/projects/linux_install/bin/mirror_sync"
ALPINE_MIRROR="rsync://dl-3.alpinelinux.org/alpine"
ARCH_MIRROR="rsync://mirrors.kernel.org/archlinux"
ARCH_SOURCE_MIRROR="rsync://mirrors.kernel.org/archlinux/sources"
ARCH32_MIRROR="rsync://mirror.archlinux32.org/archlinux32"
ARCHARM_MIRROR="rsync://de3.mirror.archlinuxarm.org/archlinux-arm"
BLACKARCH_MIRROR="rsync://blackarch.org/blackarch/blackarch"
ARCHCN_MIRROR="rsync://rsync.mirrors.ustc.edu.cn/repo/archlinuxcn"
VOID_MIRROR="rsync://mirrors.dotsrc.org/voidlinux"
ASTRA_MIRROR="rsync://repo.astralinux.ru/astra/astra"
MXISO_MIRROR="rsync://mirrors.dotsrc.org/mx-isos"
FEDORA_MIRROR="rsync://mirrors.dotsrc.org/fedora-buffet"
FEDORA_VIRTIO_MIRROR="rsync://fedorapeople.org/groups/virt/virtio-win"
CYGWIN_MIRROR="rsync://mirrors.dotsrc.org/cygwin"
APT_MIRROR="1"
ORACLE_MIRROR="1"

function mirror_rsync() {
    echo " [Mirroring from ${@: -2:1} to ${@: -1}...] {"
    [[ -d ${@: -1} ]] || mkdir -p ${@: -1}
    rsync --recursive --links --copy-unsafe-links --times --sparse --delete --delete-after --delete-excluded --progress --stats --human-readable $@
    echo -e "}\n"
}

cd 

# --- ALPINELINUX MIRROR
for al_arch in "x86_64" "x86" "aarch64" "armhf"; do
    for al_ver in "v3.12" "edge"; do
        for al_repo in "main" "community"; do
            mirror_rsync $ALPINE_MIRROR/$al_ver/$al_repo/$al_arch/ $MIRROR_DIR/alpine/$al_ver/$al_repo/$al_arch
        done
        [[ "$al_ver" != "edge" ]] && mirror_rsync $ALPINE_MIRROR/$al_ver/releases/$al_arch/ $MIRROR_DIR/alpine/$al_ver/releases/$al_arch
    done
done

# --- ARCHLINUX MIRROR
for al_repo in "core" "extra" "community"; do
    mirror_rsync $ARCH_MIRROR/$al_repo/os/x86_64/ $MIRROR_DIR/archlinux/$al_repo/os/x86_64
    mirror_rsync $ARCH32_MIRROR/i686/$al_repo/ $MIRROR_DIR/archlinux/$al_repo/os/i686
done
mirror_rsync $ARCH_MIRROR/multilib/os/x86_64/ $MIRROR_DIR/archlinux/multilib/os/x86_64
mirror_rsync $BLACKARCH_MIRROR/os/x86_64/ $MIRROR_DIR/archlinux/blackarch/os/x86_64
mirror_rsync $ARCHCN_MIRROR/x86_64/ $MIRROR_DIR/archlinuxcn/x86_64
mirror_rsync $ARCH32_MIRROR/archisos/ $MIRROR_DIR/archlinux/archisos
mirror_rsync $ARCH_SOURCE_MIRROR/ $MIRROR_DIR/arch_sources


# --- VOIDLINUX MIRROR
for al_repo in "docs" "live/current" "logos" "static" "void-updates"; do
    mirror_rsync $VOID_MIRROR/$al_repo/ $MIRROR_DIR/voidlinux/$al_repo
done
mirror_rsync --exclude "*.armv6l.xbps*" --exclude "*.armv7l.xbps*" --exclude "*.armv6l-musl.xbps*" --exclude "*.armv7l-musl.xbps*" --exclude "aarch64/debug*" --exclude "debug*" $VOID_MIRROR/current/ $MIRROR_DIR/voidlinux/current

# --- ASTRALINUX MIRROR
mirror_rsync $ASTRA_MIRROR/stable/orel/ $MIRROR_DIR/astralinux/stable/orel

# --- MX-Linux ISO MIRROR
mirror_rsync $MXISO_MIRROR/ $MIRROR_DIR/MX-Linux/MX-ISOs

# --- FEDORA MIRROR
#mirror_rsync --exclude "4*" --exclude "5*" --exclude "6*" --exclude "7*" --exclude "8.*" --exclude "testing*" $FEDORA_MIRROR $MIRROR_DIR/fedora/fedora-epel
mirror_rsync --exclude "deprecated-isos*" $FEDORA_VIRTIO_MIRROR/ $MIRROR_DIR/fedora/groups/virt/virtio-win

# --- DEBIAN-BASED DISTROS MIRROR
if [[ "$APT_MIRROR" == "1" && -f $WORK_DIR/apt-mirror-fixed && $MIRROR_DIR/apt/mirror.list ]]; then
    $WORK_DIR/apt-mirror-fixed --config $MIRROR_DIR/apt/mirror.list
    $MIRROR_DIR/debian/var/clean.sh
    $WORK_DIR/apt-mirror-fix $MIRROR_DIR/apt/mirror.list
fi

# --- CYGWIN MIRROR
mirror_rsync $CYGWIN_MIRROR/ $MIRROR_DIR/cygwin


# --- ORACLELINUX 8 MIRROR
if [[ "$ORACLE_MIRROR" == "1" && -f /usr/bin/reposync && $MIRROR_DIR/oraclelinux/config.repo ]]; then
  /usr/bin/reposync --bugfix --enhancement --newpackage --security --download-metadata --downloadcomps --remote-time --newest-only --delete --config $MIRROR_DIR/oraclelinux/config.repo -p $MIRROR_DIR/oraclelinux/mirror/
fi
