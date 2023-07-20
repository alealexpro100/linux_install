#!/bin/bash
###############################################################
### alexpro100 BASH LIBRARY
### Works both on GNU and busybox systems. Requries Bash.
### Copyright (C) 2023 ALEXPRO100 (alealexpro100)
### License: GPL v3.0
###############################################################
shopt -s expand_aliases
set -e

ALEXPRO100_LIB_VERSION="0.4.7"
ALEXPRO100_LIB_LOCATION="$(realpath "${BASH_SOURCE[0]}")"
export ALEXPRO100_LIB_VERSION ALEXPRO100_LIB_LOCATION
export CHROOT_ACTIVE_MOUNTS=() CHROOT_CREATED=() ROOTFS_DIR_NO_FIX=0
export BWRAP_MOUNTS=() FORCE_BWRAP=0 BWRAP_ROOT=""
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

# Place it before function to make it running while debug.
# NOTE: debug is defined by ALEXPRO100_LIB_DEBUG on init of alexpro100_lib.sh
function AP100_DBG() {
  [[ ! $AP100_DBG_ON == 1 ]] || "$@"
}
export -f AP100_DBG

AP100_DBG echo -e "ALEXPRO100 BASH LIBRARY $ALEXPRO100_LIB_VERSION (Debug mode)"

#--UI--

# Print decorated text.
# Has support for multi-line messages.
# Syntax: msg_print {alert|err|warn|note|msg|debug|prgs} [TEXT]
# Example: msg_print note "Your message"
function msg_print() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} {alert|err|warn|note|msg|debug|prgs} [TEXT]\nPrint decorated text."
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

# Return error with print of message
# Example: return_err "Failed!" 2
function return_err() {
  msg_print error "$1"; return "${2:-1}"
}
export -f return_err

# Print help message and return error (exit).
function echo_help() {
  msg_print warning "Printing help message."
  msg_print note "$*"
  return_err "No or incorrect arguments!"
}
export -f echo_help

# Function to show progress while executing a command.
# To use it you have to run the command in background and pass its id to this function.
# To get id of background process You can use `$!` variable after running command with end ` &`.
# Do not use it for functions, that modify external variables or arrays.
# The function in that case will work in sub-shell and won't modify external variables.
# Syntax: show_progress {sp|kit|train} [PROCESS_ID] [TEXT]
# Example: show_progress sp 1 "Your system is running..."
function show_progress() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {sp|kit|train} [PROCESS_ID] [TEXT]\nShow progress while until program complete."
  case $1 in
    sp) local sp="|\-/" s=1;;
    kit) local sp="  .   /|\  ||| <|||> |||  \|/   '  " s=5;;
    train) local sp="     < <=<=======>=> >  " s=3;;
    *) local sp="incorrect option! "; s=9;;
  esac
  local i=0 EXIT_CODE=0
  while [[ -d /proc/$2 ]]; do
    echo -ne "\e[2K [${sp:(i++)*s%${#sp}:s}]:$3 \r"
    sleep 0.5s
  done
  # See https://stackoverflow.com/questions/1570262
  wait "$2" || EXIT_CODE=$?
  echo ""
  if [[ $EXIT_CODE != 0 ]]; then
    return_err "Process $2 exited with code $EXIT_CODE!" $EXIT_CODE
  else
    return 0
  fi
}
export -f show_progress

#--SYS--

# We check to have root rights, even if they are fake
function has_root() {
  if [[ $UID != 0 ]]; then
    AP100_DBG msg_print debug "No root permission detected."
    return 1;
  else
    AP100_DBG msg_print debug "Root permission detected."
    return 0;
  fi
}
export -f has_root

# Fail-safe function to execute a command.
# Syntax: try_exec {0|1} [COMMAND]
# Example: try_exec 0 sleep
function try_exec() {
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

# Check if command exists (function or executable in PATH).
function command_exists() {
  AP100_DBG msg_print debug "Checking $1..."
  # Binary `which` seems to be outdated, so not using it.
  command -v "$1" &>/dev/null
}
export -f command_exists

# Check if argument is function (of BASH), not executable file.
function is_function() {
  AP100_DBG msg_print debug "Checking $1..."
  declare -F "$1" > /dev/null;
}
export -f is_function

# Hack for busybox. Prints list of files in directory.
# Example: list_files /mnt/ext4_1/
function list_files() {
  local DIR_SEARCH="$1"; shift
  # Busybox's find applet doesn't support option to shrink directory name.
  # WARNING: last / is important!
  find "$DIR_SEARCH" -maxdepth 1 "$@" | sort | sed "s|$DIR_SEARCH||g;/^$/d"
}
export -f list_files

# Stable, but slow way to copy bunch of files.
# Example: mv_big folder1 folder2
function mv_big() {
  for file in "$1"/*; do
    mv "$1/$file" "$2"
  done
}
export -f mv_big

# Simple check if file is binary or not.
# NOTE: May not work: https://stackoverflow.com/a/49806047
# Example: is_binary file
function is_binary() {
  (grep -q "\^@" < "$1") && return 0 || return 1
}
export -f is_binary

# This function checks only local link, NOT internet connection.
# It is intended to check local connection like enterprise network.
function check_online() {
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

# Download file to path
# Syntax: get_file_s [FILE] [URL]
# Example: get_file_s /tmp/file.bin "https://test.com/favicon.ico"
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

# Check to be available to download this URL.
# Syntax: check_url [URL]
# Example: check_url "http://test.com"
function check_url() {
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

# Check if param is url (http, https or ftp).
# Example: is_url folder2
function is_url() {
	case "$1" in
  http://*|https://*|ftp://*) return 0;;
	*) return 1;;
	esac
}
export -f is_url

# Create tmp directory
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

# Extract archive to stdout.
# Example: arccat file.tar.gz | grep test
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

# Gets list of files from html file.
# Patched to work with Fancy Index of Nginx.
function get_file_list_html() {
  sed -n '/<a / s/^.*<a [^>]*href="\([^\"]*\)".*$/\1/p' | sed '/?C=[NSM]&amp;O=[AD]/d;/[^"]*\//d'
}
export -f get_file_list_html

# Write to stdout type of machine and return result (0 - if virtual, 1 - if real).
function detect_vm() {
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
# NOTE: Non-root is WIP. For now, recursive mount is broken.

# Internal function to mount and to array pointed target.
# Example (1): chroot_add_mount dir shm "$1/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev
# Example (2): chroot_add_mount dir "/dev" "$1/dev" --bind
function chroot_add_mount() {
  [[ $1 == dir || $1 == file ]] || return_err "Wrong mount type $1!"
  if has_root && [[ ! -e $3 ]]; then
    [[ $1 == dir ]] && mkdir -p "$3"; [[ $1 == file ]] && touch "$3"
    AP100_DBG msg_print debug "Created $1 $3."
    CHROOT_CREATED=("$3" "${CHROOT_CREATED[@]}")
  fi
  AP100_DBG msg_print debug "Mounting $2..."
  shift;
  if has_root && [[ $FORCE_BWRAP != "1" ]]; then
    AP100_DBG msg_print debug "Root detected. Using real mount."
    mount "$@" || msg_print warning "$2 not mounted!"
    CHROOT_ACTIVE_MOUNTS=("$2" "${CHROOT_ACTIVE_MOUNTS[@]}")
  else
    AP100_DBG msg_print debug "Root not detected. Assuming usage of bind."

  fi
}
export -f chroot_add_mount

# Internal function intended to correctly mount chroot.
# It it used to make system tools work correctly (like pacman, xbps and etc.).
function chroot_setup() {
  [[ -d "$1" ]] || return_err "Location $1 is not directory or does not exist!"
  if ! has_root; then
    [[ -n $BWRAP_ROOT ]] || msg_print warning "Variable BWRAP_ROOT is empty. Incorrect mount will be set."
    local ROOT_MOUNT="$1"
    BWRAP_MOUNTS=("${BWRAP_MOUNTS[@]}"
      "--bind" "$ROOT_MOUNT" "${ROOT_MOUNT#"$BWRAP_ROOT"}/"
      "--proc" "${ROOT_MOUNT#"$BWRAP_ROOT"}/proc"
      "--bind" "/sys" "${ROOT_MOUNT#"$BWRAP_ROOT"}/sys"
      "--dev-bind" "/dev" "${ROOT_MOUNT#"$BWRAP_ROOT"}/dev"
      "--tmpfs" "${ROOT_MOUNT#"$BWRAP_ROOT"}/dev/shm"
      "--ro-bind" "/etc/resolv.conf" "${ROOT_MOUNT#"$BWRAP_ROOT"}/etc/resolv.conf"
    )
    AP100_DBG msg_print debug "Root is required for chroot_setup. Skipping."
    return 0
  fi
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

# Internal function like `chroot_setup` except it is made to work on non-UNIX systems (WSL1).
# Kept for manual usage.
function chroot_setup_light() {
  [[ -d "$1" ]] || return_err "Location $1 is not directory or does not exist!"
  for mount_point in proc sys dev dev/pts dev/shm run tmp; do
    chroot_add_mount dir "/$mount_point" "$1/$mount_point" --bind
  done
  for mount_point in etc/hosts etc/resolv.conf; do
    chroot_add_mount file "/$mount_point" "$1/$mount_point" --bind
  done
}
export -f chroot_setup_light

# Internal function to umount target correctly.
# By default keeps create files. 
# Think twice before using `--remove-created` option (it removes dirs and files created by this function).
function chroot_teardown() {
  AP100_DBG msg_print debug "Running ${FUNCNAME[*]}..."
  if (( ${#CHROOT_ACTIVE_MOUNTS[@]} )); then
    for name in "${CHROOT_ACTIVE_MOUNTS[@]}"; do
      AP100_DBG msg_print debug "Unmounting $name..."
      umount -l "$name" || msg_print warning "Not 0 code exit ($?)!"
    done
    CHROOT_ACTIVE_MOUNTS=()
  fi
  if (( ${#BWRAP_MOUNTS[@]} )); then
    AP100_DBG msg_print debug "Cleaning up bwrap mount params..."
    BWRAP_MOUNTS=()
  fi
  if [[ (( ${#CHROOT_CREATED[@]} )) && "$1" == "--remove-created" ]]; then
    for name in "${CHROOT_CREATED[@]}"; do
      AP100_DBG msg_print debug "Removing $name..."
      rm -rf "$name" || msg_print warning "Not 0 code exit ($?)!"
    done
    CHROOT_CREATED=()
  fi
  AP100_DBG msg_print debug "Completed ${FUNCNAME[*]}."
}
export -f chroot_teardown

# Chroot to directory with correct mount.
# Example: chroot_rootfs main /mnt/mnt bash
function chroot_rootfs() {
  # Main function to correctly run rootfs with given command.
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} {main|light} [DIRECTORY] [SHELL]\nChroot to directory with some fixes."
  [[ -d $2 ]] || return_err "$2 is not a directory!"
  AP100_DBG msg_print debug "Preparing to chroot..."
  local mode=$1 CHROOT_DIR="$2"
  shift 2;
  if has_root && [[ $ROOTFS_DIR_NO_FIX == 0 ]] && ! mountpoint -q "$CHROOT_DIR"; then
    #Dirty hack to run some programs in chroot.
    msg_print warning "Not mounted directory. Bypassing..."
    chroot_add_mount dir "$CHROOT_DIR" "$CHROOT_DIR" --bind
  fi
  if [[ $mode == "auto" ]]; then
    if has_root && [[ $FORCE_BWRAP != "1" ]]; then
      AP100_DBG msg_print debug "Auto mode enabled. Using main mode."
      mode="main"
    else
      AP100_DBG msg_print debug "Auto mode enabled. Using no_root mode."
      mode="no_root"
    fi
  fi
  chroot_setup "$CHROOT_DIR"
  case $mode in
    main)
      AP100_DBG msg_print debug "Running chroot..."
      unshare --fork chroot "$CHROOT_DIR" "$@" || local EXIT_CODE=$?
      chroot_teardown ""
    ;;
    no_root)
      AP100_DBG msg_print debug "Running bwrap..."
      BWRAP_ROOT="${BWRAP_ROOT:-CHROOT_DIR}"
      bwrap "${BWRAP_MOUNTS[@]}" --uid 0 --gid 0 --new-session --unshare-ipc --unshare-uts --cap-add CAP_SYS_CHROOT \
        --share-net -- "$@" || local EXIT_CODE=$?
    ;;
    *) return_err "Incorrect switch for mode $mode";;
  esac
  if [[ -n $EXIT_CODE && $EXIT_CODE != "0" ]]; then 
    msg_print err "Something went wrong! Code exit is $EXIT_CODE."
    return $EXIT_CODE
  fi
}
export -f chroot_rootfs

# Export distro-specific current arch in variables.
# Variables: alpine_arch debian_arch arch_arch rpm_arch void_arch qemu_arch
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

# Do chroot_rootfs using qemu to run binaries for foreign arch.
# If arch is set to check, we just check ability to use qemu static.
function qemu_chroot() {
  [[ -z $3 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [DIRECTORY] [SHELL]\nChroot to directory using qemu-static, mounting necessary directories."
  [[ "$1" == "check" ]] && shift
  local QEMU_STATIC_BIN_FILE="" QEMU_ARCH="$1"
  if [[ -n $QEMU_STATIC_BIN_DIR ]]; then
    [[ -d $QEMU_STATIC_BIN_DIR ]] || msg_print warn "Directory $QEMU_STATIC_BIN_DIR does not exist!"
    [[ ! -f $QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH-static ]] || QEMU_STATIC_BIN_FILE="$QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH-static"
    if [[ -z $QEMU_STATIC_BIN_FILE ]]; then
      if [[ -f $QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH ]]; then
        QEMU_STATIC_BIN_FILE="$QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH"
      else
        msg_print warn "Directory $QEMU_STATIC_BIN_DIR does not contain qemu-$QEMU_ARCH-static or qemu-$QEMU_ARCH!"
      fi
    fi
  fi
  if [[ -z $QEMU_STATIC_BIN_FILE ]]; then
    QEMU_STATIC_BIN_FILE="$(type -P qemu-$QEMU_ARCH-static || echo -n)"
    [[ -n $QEMU_STATIC_BIN_DIR ]] || QEMU_STATIC_BIN_FILE="$(type -P qemu-$QEMU_ARCH || echo -n)"
  fi
  [[ -n $QEMU_STATIC_BIN_FILE ]] || return_err "File qemu-$QEMU_ARCH or qemu-$QEMU_ARCH-static not found! Check qemu-static package or QEMU_STATIC_BIN_DIR variable."
  shift; [[ "$#" == 1 ]] && return 0
  cp "$QEMU_STATIC_BIN_FILE" "$1/usr/bin/qemu-$QEMU_ARCH-static"
  local qemu_dir=$1; shift
  AP100_DBG msg_print debug "Using $QEMU_STATIC_BIN_FILE."
	chroot_rootfs main "$qemu_dir" "$@"
  rm -rf "$qemu_dir/usr/bin/qemu-$QEMU_ARCH-static"
}
export -f qemu_chroot

# For running binary for foreign arch.
function qemu_run_bin() {
  [[ -z $2 ]] && echo_help "Usage: ${FUNCNAME[0]} [ARCH] [BINARY]\nRun binary using qemu-static."
  local QEMU_STATIC_BIN_FILE="" QEMU_ARCH="$1"
  if [[ -n $QEMU_STATIC_BIN_DIR ]]; then
    [[ -d $QEMU_STATIC_BIN_DIR ]] || msg_print warn "Directory $QEMU_STATIC_BIN_DIR does not exist!"
    [[ ! -f $QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH-static ]] || QEMU_STATIC_BIN_FILE="$QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH-static"
    if [[ -z $QEMU_STATIC_BIN_FILE ]]; then
      if [[ -f $QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH ]]; then
        QEMU_STATIC_BIN_FILE="$QEMU_STATIC_BIN_FILE/qemu-$QEMU_ARCH"
      else
        msg_print warn "Directory $QEMU_STATIC_BIN_DIR does not contain qemu-$QEMU_ARCH-static or qemu-$QEMU_ARCH!"
      fi
    fi
  fi
  if [[ -z $QEMU_STATIC_BIN_FILE ]]; then
    QEMU_STATIC_BIN_FILE="$(type -P qemu-$QEMU_ARCH-static || echo -n)"
    [[ -n $QEMU_STATIC_BIN_DIR ]] || QEMU_STATIC_BIN_FILE="$(type -P qemu-$QEMU_ARCH || echo -n)"
  fi
  [[ -n $QEMU_STATIC_BIN_FILE ]] || return_err "File qemu-$QEMU_ARCH or qemu-$QEMU_ARCH-static not found! Check qemu-static package or QEMU_STATIC_BIN_DIR variable."
  AP100_DBG msg_print debug "Using $QEMU_STATIC_BIN_FILE."
  shift; "$QEMU_STATIC_BIN_FILE" "$@"
}
export -f qemu_run_bin

# Lightweight version of genfstab. Generates fstab file.
function genfstab_light() {
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
