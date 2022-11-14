#!/bin/bash
###############################################################
### alexpro100 BASH LIBRARY
### Works both on GNU  and busybox systems. Requries Bash.
### Copyright (C) 2021 ALEXPRO100 (alealexpro100)
### License: GPL v3.0
###############################################################
shopt -s expand_aliases
set -e

ALEXPRO100_LIB_VERSION="0.4.2"
ALEXPRO100_LIB_LOCATION="$(realpath "${BASH_SOURCE[0]}")"
export ALEXPRO100_LIB_VERSION ALEXPRO100_LIB_LOCATION
export TMP='' CHROOT_ACTIVE_MOUNTS=() CHROOT_CREATED=() ROOTFS_DIR_NO_FIX=0
export ALEXPRO100_LIB_DEBUG="${ALEXPRO100_LIB_DEBUG:-0}"

#NOTE: Take attention to the parentheses (() or {}). They may vary.
#Quick info about them: https://stackoverflow.com/questions/6270440.

# Colors for text.

#Foreground.
export Black="\e[30m"	# Black
export DGray="\e[90m"	# Dark Gray
export DRed="\e[31m"	# Dark Red
export LRed="\e[91m"	# Light Red
export DGreen="\e[32m"	# Dark Green
export LGreen="\e[92m"	# Light Green
export Orange="\e[33m"	# Orange
export Yellow="\e[93m"	# Yellow
export Blue="\e[34m"	# Dark Blue
export LBlue="\e[94m"	# Light Blue
export DPurple="\e[35m"	# Dark Purple
export LPurple="\e[95m"	# Light Purple
export DCyan="\e[36m"	# Dark Cyan
export LCyan="\e[96m"	# Light Cyan
export LGray="\e[37m"	# Light Gray
export White="\e[97m"	# White

# Background.
export On_Black="\e[40m"       # Black
export On_Red="\e[41m"         # Red
export On_Green="\e[42m"       # Green
export On_Yellow="\e[43m"      # Yellow
export On_Blue="\e[44m"        # Blue
export On_Purple="\e[45m"      # Purple
export On_Cyan="\e[46m"        # Cyan
export On_White="\e[47m"       # White

#Special symbols.
export NC="\e[0m"		# Color Reset
export Bold="\e[1m"		# Bold text
export Cursive="\e[3m"		# Italic text
export Underline="\e[4m"	# Underlined
export Blink="\e[5m"		# Blink (might not work)
export Reverse="\e[7m"		# Negative text
export Crossout="\e[9m"		# Crossed out
export DUnderline="\e[21m"	# Double Underlined

#--DEBUG--

export AP100_DBG_ON="$ALEXPRO100_LIB_DEBUG"

function AP100_DBG() {
  [[ ! $AP100_DBG_ON == 1 ]] || "$@"
}
export -f AP100_DBG

AP100_DBG echo -e "ALEXPRO100 BASH LIBRARY $ALEXPRO100_LIB_VERSION (Debug mode)"

#--UI--

function msg_print() {
  # Prints decorated text. Has support for multi-line messages.
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} {alert|err|warn|note|msg|debug|prgs} [TEXT]]\nPrint decorated text."
  local line TYPE=$1; shift
  while IFS= read -r line; do
    case $TYPE in
      alert) echo -e "$Bold$White$On_Red$line${NC}";;
      err|error) echo -e "[${LRed}ERROR${NC}] $line";;
      warn|warning) echo -e "[${Orange}WARNING${NC}] $line";;
      note) echo -e "[${LBlue}NOTE${NC}] $line";;
      msg|meassage) echo -e "[${DGray}MSG${NC}] $line";;
      debug) echo -e "[${LGreen}DEBUG${NC}] $line";;
      prgs|progress) echo -e "[${Orange}PROGRESS${NC}] $line";;
      *) return_err "Incorrect type $TYPE!";;
    esac
  done < <(echo -e "$*")
}
export -f msg_print

function return_err() {
  msg_print error "$1"; return "${2:-1}"
}
export -f return_err

function echo_help() {
  msg_print warning "Printing help message."
  msg_print note "$*"
  return_err "No or incorrect arguments!"
}
export -f echo_help

function show_progress() {
  # Function to show progress while executing a command.
  #
  # To use it you have to run the command in background and pass its id to this function.
  # To get id of background process You can use `$!` variable after running command with end ` &`.
  #
  # Do not use it for functions, that modify external variables or arrays.
  # The function in that case will work in sub-shell and won't modify external variables.
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {sp|kit|train} [PROCESS_ID] [TEXT]\nShow progress while until program complete."
  case $1 in
    sp) local sp="|\-/" s=1;;
    kit) local sp="  .   /|\  ||| <|||> |||  \|/   '  " s=5;;
    train) local sp="     < <=<=======>=> >  " s=3;;
    *) local sp="incorrect option! "; s=9;;
  esac
  local i=0;
  while [[ -d /proc/$2 ]]; do
    echo -ne "\e[2K [${sp:(i++)*s%${#sp}:s}]:$3 \r"
    sleep 0.5s
  done
  echo ""
}
export -f show_progress

#--SYS--

function try_exec() {
  # Fail-safe function to execute a command.
  [[ -z $2 || ( $1 != "0" && $1 != "1" ) ]] && echo_help "Usage: ${FUNCNAME[0]} {0|1} [COMMAND]\nTry to execute command."
  local RETURN_ERR=$1; shift
  if "$@"; then
    AP100_DBG msg_print debug "Succesfully executed command: $*"
  else
    if [[ $RETURN_ERR == "1" ]]; then
      return_err "Failed to execute command: $*." $?
    else
      msg_print warning "Failed to execute command: $*."
    fi
  fi 
}
export -f try_exec

function command_exists() {
  AP100_DBG msg_print debug "Checking $1..."
  command -v "$1" &>/dev/null
}
export -f command_exists

function is_function() {
  AP100_DBG msg_print debug "Checking $1..."
  declare -F "$1" > /dev/null;
}
export -f is_function

function list_files() {
  # Hack for busybox. Prints list of files in directory.
  # Busybox's find applet doesn't support option to shrink directory name.
  local DIR_SEARCH="$1"; shift
  find "$DIR_SEARCH" -maxdepth 1 "$@" | sort | sed "s|$DIR_SEARCH||g;/^$/d"
}
export -f list_files

function mv_big() {
  for file in "$1"/*; do
    mv "$1/$file" "$2"
  done
}
export -f mv_big

function check_online() {
  # It does NOT detect internet connection, only local link is checked.
  # It is intended to check local connection like enterprise network.
  local offline=1
  while IFS= read -r interface; do
    AP100_DBG msg_print debug "Checking $interface for carrier."
    if [[ $(cat "/sys/class/net/$interface/carrier" 2>/dev/null) = 1 ]]; then
      AP100_DBG msg_print debug "Found carrier on $interface."
      offline=0; break
    fi
  done < <(list_files /sys/class/net/ -type l | sed '/lo/d')
  return $offline;
}
export -f check_online

function get_file_s() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [FILE] [URL]\nDownload to file from url."
  if command_exists wget &>/dev/null; then
    [[ $1 == - ]] || AP100_DBG msg_print debug "Using wget."
    wget -c -q -t 3 -O "$1" "$2" || return_err "Exit code $? (wget) while downloading $2!"
  elif command_exists curl &>/dev/null; then
    [[ $1 == - ]] || AP100_DBG msg_print debug "Using curl."
    curl -C - --retry 3 -f -o "$1" "$2" || return_err "Exit code $? (curl) while downloading $2!"
  else
    return_err "Niether wget nor curl are found."
  fi
}
export -f get_file_s

function check_url() {
  # Check to be available to download this URL.
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [URL]\nCheck url to be downloadable."
  is_url "$1" || return_err "Parameter $1 is not downloadable URL."
  AP100_DBG msg_print debug "Checking URL: $1..."
  if command_exists wget; then
    AP100_DBG msg_print debug "Using wget."
    wget -q --spider "$1" &>/dev/null
  elif command_exists curl; then
    AP100_DBG msg_print debug "Using curl."
    curl --head --fail "$1" &>/dev/null
  else
    return_err "Niether wget nor curl are found."
  fi
}
export -f check_url

function is_url() {
	case "$1" in
  http://*|https://*|ftp://*) return 0;;
	*) return 1;;
	esac
}
export -f is_url

function create_tmp_dir() {
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [VARIABLE]\nCreate temporary directory and assign it to variable."
  local dir="/tmp/.$1_tmp_$RANDOM"
  if [[ -d $dir ]]; then
    create_tmp_dir "$1"
  else
    export "$1=/tmp/.$1_tmp_$RANDOM"
    mkdir -p "${!1}" &>/dev/null
    AP100_DBG msg_print debug "Created tmp dir $1=${!1}."
  fi
}
export -f create_tmp_dir

function arccat() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [TYPE] [FILE]\nExtract archive to stdout."
  [[ $2 == "-" || -f $2 ]] || return_err "File $2 does NOT exist."
  case "$1" in
    zst|zstd) zstd -dcf "$2";;
    bz2)  bunzip2 "$2";;
    Z|gz)  gunzip -cd "$2";;
    xz)  xz -d "$2";;
    tar)  tar xf "$2" -O;;
    rar)  unrar x "$2";;
    zip)  unzip -p "$2";;
    7z)  7z x -so "$2" 2>/dev/null;;
    *)  return_err "$1 - Unknown archive type.";;
  esac
}
export -f arccat

function unpack_cpio() (
  cd -- "$1" || return_err "Cannot cd to $1!"
  cpio -idm &>/dev/null
)
export -f unpack_cpio

function pack_initfs_cpio() (
  cd -- "$1" || return_err "Cannot cd to $1!"
  find . | cpio --quiet -H newc -o
)
export -f pack_initfs_cpio

function squashfs_rootfs_pack() (
  local dir="$1" file="$2"; shift 2
  cd -- "$dir" || return_err "Cannot cd to $dir!"
  mksquashfs . "$file" -noappend "${@}"
)
export -f squashfs_rootfs_pack

# -- PARSERS

function get_file_list_html() {
  # Gets list of files from html file.
  # Patched to work with Fancy Index of Nginx.
  sed -n '/<a / s/^.*<a [^>]*href="\([^\"]*\)".*$/\1/p' | sed '/?C=[NSM]&amp;O=[AD]/d;/[^"]*\//d'
}
export -f get_file_list_html

function detect_vm() {
  # Will write to stdout detected type and/or return result.
  for type in ${1:-'VMware, Inc.' 'Xen' 'KVM' 'VirtualBox' 'Standard PC (Q35 + ICH9, 2009)' 'Standard PC (i440FX + PIIX, 1996)'}; do
    AP100_DBG msg_print debug "Testing $type..."
    if [[ "$(dmidecode -s system-product-name)" == "$type" ]]; then
      echo "$type"
      return 0
    fi
  done
  return 1
}
export -f detect_vm

#--- ROOTFS MOUNT: BEGIN

# Aim of this bunch of functions is to correctly mount rootfs for correct work of many scripts and package managers (such as pacman).

function chroot_add_mount() {
  # Internal function to mount and to array pointed target.
  if [[ ! -e $3 ]]; then
    [[ $1 == dir ]] && mkdir -p "$3"; [[ $1 == file ]] && touch "$3"
    AP100_DBG msg_print debug "Created $1 $3."
    CHROOT_CREATED=("$3" "${CHROOT_CREATED[@]}")
  fi
  AP100_DBG msg_print debug "Mounting $2..."
  shift; mount "$@" || msg_print warning "$2 not mounted!"
  CHROOT_ACTIVE_MOUNTS=("$2" "${CHROOT_ACTIVE_MOUNTS[@]}")
}
export -f chroot_add_mount

function chroot_setup() {
  # Internal function intended to correctly mount chroot.
  # It it used to make system tools work correctly.
  AP100_DBG msg_print debug "Running ${FUNCNAME[*]}..."
  chroot_add_mount dir proc "$1/proc" -t proc -o nosuid,noexec,nodev
  chroot_add_mount dir sys "$1/sys" -t sysfs -o nosuid,noexec,nodev,ro
  [[ -d '/sys/firmware/efi/efivars' ]] && chroot_add_mount dir efivarfs "$1/sys/firmware/efi/efivars" -t efivarfs -o nosuid,noexec,nodev
  chroot_add_mount dir udev "$1/dev" -t devtmpfs -o mode=0755,nosuid
  chroot_add_mount dir devpts "$1/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec
  chroot_add_mount dir shm "$1/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev
  if [[ ! -d "$1/etc" ]]; then
    mkdir -p "$1/etc"; CHROOT_CREATED=("$1/etc" "${CHROOT_CREATED[@]}")
    AP100_DBG msg_print debug "Created $1/etc."
  fi
  for mp in etc/hosts etc/resolv.conf; do 
    chroot_add_mount file "/$mp" "$1/$mp" --bind
  done
  chroot_add_mount dir "/run" "$1/run" --bind
  chroot_add_mount dir tmp "$1/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid
  AP100_DBG msg_print debug "Completed ${FUNCNAME[*]}."
}
export -f chroot_setup

function chroot_setup_light() {
  # Internal function like `chroot_setup` except it is made to work on non-UNIX systems (WSL1).
  # Kept for manual usage.
  for mount_point in proc sys dev dev/pts dev/shm run tmp; do
    chroot_add_mount dir "/$mount_point" "$1/$mount_point" --bind
  done
  for mount_point in etc/hosts etc/resolv.conf; do
    chroot_add_mount file "/$mount_point" "$1/$mount_point" --bind
  done
}
export -f chroot_setup_light

function chroot_teardown() {
  # Internal function to umount target correctly.
  # By default keeps create files. 
  # Think twice before using `--remove-created` option.
  AP100_DBG msg_print debug "Running ${FUNCNAME[*]}..."
  if (( ${#CHROOT_ACTIVE_MOUNTS[@]} )); then
    for name in "${CHROOT_ACTIVE_MOUNTS[@]}"; do
      AP100_DBG msg_print debug "Unmounting $name..."
      umount -l "$name" || msg_print warning "Not 0 code exit!"
    done
    if [[ "$1" == "--remove-created" ]]; then
      for name in "${CHROOT_CREATED[@]}"; do
        AP100_DBG msg_print debug "Removing $name..."
        rm -rf "$name" || msg_print warning "Not 0 code exit!"
      done
    fi
  fi
  unset CHROOT_ACTIVE_MOUNTS CHROOT_CREATED
  AP100_DBG msg_print debug "Completed ${FUNCNAME[*]}."
}
export -f chroot_teardown

function chroot_rootfs() {
  # Main function to correctly run rootfs with given command.
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {main|light} [DIRECTORY] [SHELL]\nChroot to directory mounting necessary directories."
  [[ -d $2 ]] || return_err "$2 is not a directory!"
  AP100_DBG msg_print debug "Preparing to chroot..."
  local mode=$1
  local CHROOT_DIR="$2"; shift 2; [[ -z $CHROOT_COMMAND ]] && local CHROOT_COMMAND=chroot
  if [[ $ROOTFS_DIR_NO_FIX == 0 ]] && ! mountpoint -q "$CHROOT_DIR"; then
    #Dirty hack to run some programs in chroot.
    msg_print warning "Not mounted directory. Bypassing..."
    chroot_add_mount dir "$CHROOT_DIR" "$CHROOT_DIR" --bind
  fi
  case $mode in
    light) chroot_setup_light "$CHROOT_DIR";;
    main|*) chroot_setup "$CHROOT_DIR";;
  esac
  AP100_DBG msg_print debug "Running chroot..."
  unshare --fork $CHROOT_COMMAND "$CHROOT_DIR" "$@" || local EXIT_CODE=$? 
  chroot_teardown ""
  if [[ -n $EXIT_CODE && $EXIT_CODE != "0" ]]; then 
    msg_print err "Something went wrong! Code exit is $EXIT_CODE."
    return $EXIT_CODE
  fi
}
export -f chroot_rootfs

function parse_arch() {
  # Generally used to get distro-specific arch names.
  case $1 in
    i[3-6]86|x86) export alpine_arch=x86 debian_arch=i386 arch_arch=i686 rpm_arch=x86 void_arch=i686 qemu_arch=i386;;
    x86_64|amd64) export alpine_arch=x86_64 debian_arch=amd64 arch_arch=x86_64 rpm_arch=x86_64 void_arch=x86_64 qemu_arch=x86_64;;
    aarch64|arm64|armv8l) export alpine_arch=aarch64 debian_arch=arm64 arch_arch=aarch64 rpm_arch=aarch64 void_arch=aarch64 qemu_arch=aarch64;;
    armv7*) export alpine_arch=armv7 debian_arch=armhf arch_arch=armv7h rpm_arch=armv7hl void_arch=armv7l qemu_arch=arm;;
    armhf|armv6*) export alpine_arch=armhf debian_arch=armhf arch_arch=armv6h rpm_arch=armhfp void_arch=armv6l qemu_arch=arm;;
    arm|armel) export alpine_arch=armhf debian_arch=armel arch_arch=arm rpm_arch=armhfp void_arch=armv6l qemu_arch=arm;;
    s390x|ppc64*|mips*) qemu_arch="$1"; export alpine_arch="$qemu_arch" debian_arch="$qemu_arch" arch_arch="$qemu_arch" rpm_arch="$qemu_arch" void_arch="$qemu_arch" qemu_arch;;
    *) qemu_arch="$(uname -m)"; export alpine_arch="$qemu_arch" debian_arch="$qemu_arch" arch_arch="$qemu_arch" rpm_arch="$qemu_arch" void_arch="$qemu_arch" qemu_arch;;
  esac
  AP100_DBG msg_print debug "Exported alpine_arch=$alpine_arch debian_arch=$debian_arch arch_arch=$arch_arch rpm_arch=$qemu_arch void_arch=$void_arch qemu_arch=$qemu_arch."
}
export -f parse_arch

function qemu_chroot() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [DIRECTORY] [SHELL]\nChroot to directory using qemu-static, mounting necessary directories."
  local QEMU_STATIC_BIN_DIR=${QEMU_STATIC_BIN_DIR:-"/usr/bin"}
  # If arch is set to check, we just check ability to use qemu static.
  [[ "$1" == "check" ]] && shift
  parse_arch "$1"; shift
  if [[ -f $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static ]]; then
    AP100_DBG msg_print debug "Using $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static."
    [[ "$#" == 1 ]] && return 0
    cp "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" "$1/usr/bin/qemu-$qemu_arch-static"
    local qemu_dir=$1; shift
	  chroot_rootfs main "$qemu_dir" "qemu-$qemu_arch-static" "$@"
    rm -rf "$1/usr/bin/qemu-$qemu_arch-static"
  else
    return_err "File $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static not found! Check qemu-static package."
  fi
}
export -f qemu_chroot

function qemu_run_bin() {
  #For running binary for foreign arch.
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [BINARY]\nRun binary using qemu-static."
  local QEMU_STATIC_BIN_DIR=${QEMU_STATIC_BIN_DIR:-"/usr/bin"}
  if [[ -f "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" ]]; then
    AP100_DBG msg_print debug "Found $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static."
    shift; "$QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static" "$@"
  else
    return_err "File $QEMU_STATIC_BIN_DIR/qemu-$qemu_arch-static not found! Check qemu-static package."
  fi
}
export -f qemu_run_bin

function genfstab_light() {
  # It is lightweight version of genfstab. It is used to generate fstab file.
  [[ -z $1 ]] && echo_help "Usage: ${FUNCNAME[0]} [DIRECTORY]\nMake fstab file for directory."
  local root
  root=$(realpath "$1")
  declare -A pseudofs_types=([anon_inodefs]=1 [autofs]=1 [bdev]=1 [bpf]=1 [binfmt_misc]=1 [cgroup]=1 [cgroup2]=1 [configfs]=1 [cpuset]=1 [debugfs]=1
  [devfs]=1 [devpts]=1 [devtmpfs]=1 [dlmfs]=1 [efivarfs]=1 [fuse.gvfsd-fuse]=1 [fuse.gvfs-fuse-daemon]=1 [fusectl]=1 [gvfsd-fuse]=1 [hugetlbfs]=1 [mqueue]=1 [nfsd]=1 [none]=1 [pipefs]=1
  [proc]=1 [pstore]=1 [ramfs]=1 [rootfs]=1 [rpc_pipefs]=1 [securityfs]=1 [sockfs]=1 [spufs]=1 [sysfs]=1 [tracefs]=1 [tmpfs]=1)
  declare -A fsck_types=([cramfs]=1 [exfat]=1 [ext2]=1 [ext3]=1 [ext4]=1 [ext4dev]=1 [jfs]=1 [minix]=1 [msdos]=1 [reiserfs]=1 [vfat]=1 [xfs]=1)
  findmnt -Recvruno SOURCE,TARGET,FSTYPE,OPTIONS,FSROOT "$root" |
  while read -r src target fstype opts fsroot; do
    (( pseudofs_types["$fstype"] )) && continue
    dump=0 pass=0
    target=${target#"$root"}
    if [[ $fsroot != "/" && $fstype != "btrfs" ]]; then
      src=$(findmnt -funcevo TARGET "$src")$fsroot #bind mount
      [[ ! $src -ef "$target" ]] && echo -ne "\n# $src\n$src\t/${target#/}\tnone\t$opts,bind\t$dump $pass\n"
      continue
    fi
    (( fsck_types["$fstype"] )) && pass=2
    case $fstype in
      fuseblk) fstype=$(lsblk -no FSTYPE "$src");; #For ntfs-3g
      fuse*) continue;; #We just ignore fuse mounts.
      *) findmnt "$src" "$root" >/dev/null && pass=1;;
    esac
    echo -ne "\n# $src"; 
    label=$(lsblk -rno LABEL "$src" 2>/dev/null)
    [[ -n $label ]] && echo -ne " LABEL=$label"
    echo -ne "\nUUID=$(lsblk -rno UUID "$src" 2>/dev/null)\t/${target#/}\t$fstype\t$opts\t$dump $pass\n"
  done
}
export -f genfstab_light

#--- ROOTFS MOUNT: END
