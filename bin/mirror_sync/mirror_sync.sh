#!/bin/bash
###############################################################
### Mirror sync script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

declare -gx MIRROR_DIR="/mnt/mirror"
declare -gx REPOS_DIR="$MIRROR_DIR/git"
WORK_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
ALPINE_MIRROR="rsync://dl-3.alpinelinux.org/alpine"
ARCH_MIRROR="rsync://mirrors.kernel.org/archlinux"
ARCH_SOURCE_MIRROR="rsync://mirrors.kernel.org/archlinux/sources"
ARCH32_MIRROR="rsync://mirror.archlinux32.org/archlinux32"
#ARCHARM_MIRROR="rsync://de3.mirror.archlinuxarm.org/archlinux-arm"
BLACKARCH_MIRROR="rsync://blackarch.org/blackarch/blackarch"
ARCHCN_MIRROR="rsync://rsync.mirrors.ustc.edu.cn/repo/archlinuxcn"
VOID_MIRROR="rsync://mirrors.dotsrc.org/voidlinux"
ASTRA_MIRROR="rsync://repo.astralinux.ru/astra/astra"
MXISO_MIRROR="rsync://mirrors.dotsrc.org/mx-isos"
#FEDORA_MIRROR="rsync://mirrors.dotsrc.org/fedora-buffet"
FEDORA_VIRTIO_MIRROR="rsync://fedorapeople.org/groups/virt/virtio-win"
CYGWIN_MIRROR="rsync://mirrors.dotsrc.org/cygwin"
APT_MIRROR="1" APT_MIRROR_FIX="0"
ORACLE_MIRROR="1"

function mirror_rsync() {
    echo " [Mirroring from ${*: -2:1} to ${*: -1}...] {"
    [[ -d "${*: -1}" ]] || mkdir -p "${*: -1}"
    rsync --recursive --links --copy-unsafe-links --times --sparse --delete --delete-after --delete-excluded --progress --stats --human-readable "$@"
    echo -e "}\n"
}

function git_update() {
    repo_name="$*"
    repo="$(echo "$repo_name" | cut -d' ' -f1)"
    name="$(echo "$repo_name" | cut -d' ' -f2)"
    echo " [Git update $name to $REPOS_DIR/$name...]"
    if [[ -d "$REPOS_DIR/$name/.git" ]]; then
        git -C "$REPOS_DIR/$name" pull origin master --rebase
    else
        mkdir -p "$REPOS_DIR/$name"
        git clone "$repo" "$REPOS_DIR/$name"
    fi
}

cd "$MIRROR_DIR"

while IFS= read -r repo_name; do
    git_update "$repo_name"
done < <(cat ./list.git/alpine)
#while IFS= read -r repo_name; do
#    git_update "$repo_name"
#done < <(cat ./list.git/openwrt)

# --- ALPINELINUX MIRROR
for al_arch in "x86_64" "x86" "aarch64" "armhf"; do
    for al_ver in "v3.13" "edge"; do
        for al_repo in "main" "community"; do
            mirror_rsync $ALPINE_MIRROR/$al_ver/$al_repo/$al_arch/ alpine/$al_ver/$al_repo/$al_arch
        done
	[[ "$al_ver" == "edge" ]] && mirror_rsync $ALPINE_MIRROR/$al_ver/testing/$al_arch/ alpine/$al_ver/testing/$al_arch
        [[ "$al_ver" != "edge" ]] && mirror_rsync $ALPINE_MIRROR/$al_ver/releases/$al_arch/ alpine/$al_ver/releases/$al_arch
    done
done

# --- ARCHLINUX MIRROR
for al_repo in "core" "extra" "community"; do
    mirror_rsync $ARCH_MIRROR/$al_repo/os/x86_64/ archlinux/$al_repo/os/x86_64
    mirror_rsync $ARCH32_MIRROR/i686/$al_repo/ archlinux/$al_repo/os/i686
done
mirror_rsync $ARCH_MIRROR/multilib/os/x86_64/ archlinux/multilib/os/x86_64
mirror_rsync $BLACKARCH_MIRROR/os/x86_64/ archlinux/blackarch/os/x86_64
mirror_rsync $ARCHCN_MIRROR/x86_64/ archlinuxcn/x86_64
mirror_rsync $ARCH32_MIRROR/archisos/ archlinux/archisos
mirror_rsync $ARCH_SOURCE_MIRROR/ arch_sources


# --- VOIDLINUX MIRROR
for al_repo in "docs" "live/current" "logos" "static" "void-updates"; do
    mirror_rsync $VOID_MIRROR/$al_repo/ voidlinux/$al_repo
done
mirror_rsync --exclude "*.armv6l.xbps*" --exclude "*.armv7l.xbps*" --exclude "*.armv6l-musl.xbps*" --exclude "*.armv7l-musl.xbps*" --exclude "aarch64/debug*" --exclude "debug*" $VOID_MIRROR/current/ voidlinux/current

# --- ASTRALINUX MIRROR
mirror_rsync $ASTRA_MIRROR/stable/orel/ astralinux/stable/orel

# --- MX-Linux ISO MIRROR
mirror_rsync $MXISO_MIRROR/ MX-Linux/MX-ISOs

# --- FEDORA MIRROR
#mirror_rsync --exclude "4*" --exclude "5*" --exclude "6*" --exclude "7*" --exclude "8.*" --exclude "testing*" $FEDORA_MIRROR fedora/fedora-epel
mirror_rsync --exclude "deprecated-isos*" $FEDORA_VIRTIO_MIRROR/ fedora/groups/virt/virtio-win

# --- DEBIAN-BASED DISTROS MIRROR
if [[ "$APT_MIRROR" == "1" && -f "$WORK_DIR/apt-mirror-fixed" && -f apt/mirror.list ]]; then
    "$WORK_DIR/apt-mirror-fixed" --config apt/mirror.list
    debian/var/clean.sh
    [[ "$APT_MIRROR_FIX" == "1" ]] && "$WORK_DIR/apt-mirror-fix" apt/mirror.list
fi

# --- CYGWIN MIRROR
mirror_rsync $CYGWIN_MIRROR/ cygwin


# --- ORACLELINUX 8 MIRROR
if [[ "$ORACLE_MIRROR" == "1" && -f /usr/bin/reposync && -f oraclelinux/config.repo ]]; then
  /usr/bin/reposync --bugfix --enhancement --newpackage --security --download-metadata --downloadcomps --remote-time --newest-only --delete --config oraclelinux/config.repo -p oraclelinux/mirror/
fi
