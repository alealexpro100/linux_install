#!/bin/bash

# shellcheck disable=SC2034

#Default variables for translation.
LANG_SYSTEM="en_US.UTF-8"

#Messages for english language.
M_PROJECT_NAME="Linux install script"
M_YES="Yes"
M_NO="No"
M_EXIT_BUTTON="Exit"
M_CANCEL_BUTTON="Back"
M_CONFIRM="Do you really want continue?"
M_WELCOME="Welcome to linux_install script"
M_MSG_OPT="Translation"
M_DIR_WARN="This script supposes that directory for installation is prepared."
M_PROFILE_1="Profile will be written into"
M_PATH="Path to install"
M_DISTR_1="Available distributions"
M_DISTR_2="Distribution"
M_COMMON_OPT="Common options."
M_DISTR_OPT="Distro-specific options."
M_LIST_END_OPTION="End (proceed to next step)."
M_LIST__TEXT="Generated options.\n"
M_LIST_DIALOG="Choose option"
M_CHANGE_FINAL_DIALOG="Change option"
M_LIST_FINAL_OPTION="End (generate profile and exit)."
M_LIST_FINAL_OPTION_LIVE="End (start installing system)."
M_NICE="Script successfully ended its work. Have a nice day!"

M_LANG_SYSTEM="Language (locale) of system"
M_HOSTNAME="Hostname"
M_USER="Name of user"
M_SHELL="Shell for user"
M_PASS="Password"
M_PASS_NO="No password entered. Password set to"
M_FSTAB="Generate fstab?"
M_BOOTLOADER="Install bootloader?"
M_BOOTLOADER_TYPE="Type of bootloader"
M_BOOTLOADER_NAME="Name of bootloader"
M_BOOTLOADER_PATH="Where to install bootloader"
M_BOOTLOADER_REMOVABLE="Is OS installing to removable disk?"
M_BOOTLOADER_UEFI_VFAT_NO="No vfat partition found on"
M_ADD_SOFT="Install additional soft?"
M_NETWORKMANAGER="Install NetworkManager?"
M_SSH="Install SSH client and server?"
M_PULSEAUDIO="Add audio support (pulseaudio)?"
M_PIPEWIRE="Add audio support (pipewire)?"
M_BLUETOOTH="Add bluetooth support?"
M_PRINTERS="Add printers support?"
M_ARCH_AVAL="Available architectures:"
M_ARCH_ENTER="Architecture"
M_MIRROR="Mirror"
M_KERNEL="Install kernel?"
M_KERNEL_TYPE="Type of kernel"
M_PACK="Packages for installation"
M_PACK="Packages for preinstallation"
M_DISTR_VER="Version of distribution"
M_MULTILIB="Enable (add) multilib repo?"

M_GRAPH="Install graphics?"
M_GRAPH_TYPE_M="Wayland is not tested.\n"
M_GRAPH_TYPE="Enter type of graphics"
M_DESKTOP_TYPE_M="DE - Desktop environment.\nWM - window manager.\nM - manual install.\n"
M_DESKTOP_TYPE="Enter desktop type"
M_DESKTOP_DE="Enter chosen DE"
M_DESKTOP_WM="Enter chosen WM"
M_DESKTOP_SOFT="Additional software."
M_FIREFOX="Install firefox?"
M_CHROMIOUM="Install chromium?"
M_OFFICE="Install office software?"
M_ADMIN_SOFT="Install administration software?"
M_DESKTOP_MANUAL_PKGS="Enter desktop package(s) or nothing"
M_DM_E="Install and enable display manager?"
M_DM="Enter DM name"

M_DEB_REPO_1="To remove repo, just leave it empty."
M_DEB_REPO_DIALOG="Repository"
M_DEB_REPO_TEXT="Repositories"
M_DEB_BACKPORTS_KERNEL="Install backports kernel instead of stable?"
M_DEB_NO_RECOMMENDS="Do NOT install recommended packages (APT parameter)?"

#Messages for installer.
M_MODE_AUTO="Working in auto mode."
M_MODE_AUTO_FAIL="Auto mode returned error."
M_MODE_MANUAL="Working in manual mode."
M_MODE_CONSOLE_M="To run installer, type \"./linux_install/profile_gen.sh\" and then \"./linux_install/install_sys.sh\""
M_HOST_OFFLINE="Host is offline!"
M_HOST_ONLINE="Host is online."
M_LOCAL_IP="Local IP address"
M_NET_INTERFACE_DETECTED_LIST="Detected network interfaces"
M_NET_INTERFACE_CHOOSE="Choose interface to setup"
M_NET_DHHCP_TRY="Setting up DHCP on interface"
M_NET_DHCP_FAIL="Failed to setup DHCP."
M_NET_WIFI_SCAN_RESULT="Scan result"
M_NET_WIFI_SSID_CHOOSE="Choose SSID"
M_NET_WIFI_SSID_PASS="Enter password for"
M_NET_ETH_METHOD="Choose method"
M_WORK_MODE="Work mode"
M_PART_WARN="ALL DATA ON CHOSEN DISK WILL BE ERASED!"
M_PART_MODE="Partition mode"
M_PART="Partition disk?"
M_PART_D_M="Detected partition scheme"
M_PART_D="Disk"
M_PART_P="Partition"
M_PART_I_M="Partition for linux system. It will be formatted to ext4 filesystem."
M_PART_B_M="Partition (disk) for bootloader."
M_CHANGE_DO="Do changes?"
M_FORMAT="Formatting"
M_MOUNT="Mounting"
M_CHANGE_C="Complete!"
M_ECHO_MODE="Echo mode"
M_END_OPTION_REBOOT="Reboot machine"
M_END_OPTION_POWEROFF="Power off machine"
M_END_OPTION_CONSOLE="Enter console"
M_REBOOT_M="Complete! To reboot, type \"reboot\""


declare -A M_VAR_DESCRIPTION=(
    [dir]="$M_PATH"
    [distr]="$M_DISTR_2"
    [LANG_SYSTEM]="$M_LANG_SYSTEM"
    [hostname]="$M_HOSTNAME"
    [user_name]="$M_USER"
    [user_shell]="$M_SHELL"
    [passwd]="$M_PASS"
    [fstab]="$M_FSTAB"
    [bootloader]="$M_BOOTLOADER"
    [bootloader_type]="$M_BOOTLOADER_TYPE"
    [bootloader_name]="$M_BOOTLOADER_NAME"
    [bootloader_bios_place]="$M_BOOTLOADER_PATH"
    [removable_disk]="$M_BOOTLOADER_REMOVABLE"
    [copy_setup_script]="$M_COPYSCRIPT"
    [add_soft]="$M_ADD_SOFT"
    [networkmanager]="$M_NETWORKMANAGER"
    [pulseaudio]="$M_PULSEAUDIO"
    [pipewire]="$M_PIPEWIRE"
    [bluetooth]="$M_BLUETOOTH"
    [printers]="$M_PRINTERS"
    [arch]="$M_ARCH_ENTER"
    [kernel]="$M_KERNEL"
    [kernel_type]="$M_KERNEL_TYPE"
    [preinstall]="$M_PACK_PRE"
    [postinstall]="$M_PACK"
    [mirror_archlinux]="Archlinux: $M_MIRROR"
    [arch_add_i386]="Archlinux: $M_MULTILIB"
    [mirror_alpine]="Alpine: $M_MIRROR"
    [version_alpine]="Alpine: $M_DISTR_VER"
    [version_debian]="Debian: $M_DISTR_VER"
    [debian_add_i386]="Debian: $M_MULTILIB"
    [debian_repos]="Debian: $M_DEB_REPO_TEXT"
    [mirror_voidlinux]="Voidlinux: $M_MIRROR"
    [version_void]="Voidlinux: $M_DISTR_VER"
    [void_add_i386]="Voidlinux: $M_MULTILIB"
)