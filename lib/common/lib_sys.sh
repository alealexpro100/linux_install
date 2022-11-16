#!/bin/bash

# Tested to work under Alpine Linux.

# Network setup functions.
# This is light way to setup network without configs or managers like NetworkManager

# Get list of interfaces like 'eth0\neth1'
function interfaces_get_list() {
    list_files "/sys/class/net/" -type l | sed '/lo/d'
}

# Use DHCP to get connection
# Example: interface_setup_dhcp eth0
function interface_setup_dhcp() {
    msg_print note "${M_NET_DHHCP_TRY:-Setting up DHCP on interface} $1..."
    try_exec 0 ifconfig "$1" 0.0.0.0
    timeout 10 udhcpc -i "$1" -f -q || msg_print error "${M_NET_DHCP_FAIL-Failed to setup DHCP}"
}
export -f interface_setup_dhcp

# Use static ip address mapping
# Example: interface_setup_static eth0 192.168.88.34 255.255.255.0
function interface_setup_static() {
    local interface="$1" ip_client="$2" ip_netmask="$3" ip_gateway="$4" ip_dns="$5"
    AP100_DBG msg_print debug "Setting up interface $1 using static address $ip_client netmask $ip_netmask"
    if ifconfig "$interface" "$ip_client" netmask "$ip_netmask"; then
        [[ -z "$ip_gateway" ]] || ip route add 0.0.0.0/0 via "$ip_gateway" dev "$interface"
    else
        return_err "Failed to setup static on $interface!"
    fi
    [[ -z $ip_dns ]] || echo "nameserver $ip_dns" >> /etc/resolv.conf
}
export -f interface_setup_static

# Returns list of networks like 'network1\nnetwork2'
function scan_for_networks() {
    iwlist "$1" scanning | awk -F ':' '/ESSID:/ {print $2;}' | sed 's/\"//g'
}

# Setup wifi connection to AP
# Example: interface_con_wlan net123 pass123456 dhcp
function interface_con_wlan() {
    local interface="$1" ssid="$2" ssid_pass="$3" ip_method="${4:-dhcp}"
    # If not static, can be skipped
    local ip_client="$5" ip_netmask="$6" ip_gateway="$7" ip_dns="$8"
    try_exec 0 ip link set "$interface" up
    iwconfig "$interface" essid "$ssid"
    if wpa_conf="$(wpa_passphrase "$ssid" "$ssid_pass")"; then
        if echo -n "$wpa_conf" | wpa_supplicant -B -i "$interface"; then
            case $ip_method in
                auto|dhcp) interface_setup_dhcp "$interface";;
                static) interface_setup_static "$interface" "$ip_client" "$ip_netmask" "$ip_gateway" "$ip_dns";;
                *) return_err "Incorrect paramater ip_method!"
            esac
        fi
    else
        msg_print error "$wpa_conf"
    fi
}
export -f interface_con_wlan

function interface_get_ip() {
    local interface="$1"
    if [[ $(cat "/sys/class/net/$interface/carrier" 2>/dev/null) = 1 ]]; then
        if [[ $(ip addr) =~ inet\ ([0-9\.]+)\/[0-9]+\ [a-z0-9\.\ ]+\ $interface ]]; then
            echo -n "${BASH_REMATCH[1]}"
        fi
    else
        return_err "Interface $interface is down!"
    fi
}

function interfaces_get_ip() {
    local interface ip_addr
    while IFS= read -r interface; do
        if [[ $(cat "/sys/class/net/$interface/carrier" 2>/dev/null) = 1 ]]; then
            if ip_addr=$(interface_get_ip $interface); then
                msg_print note "$M_LOCAL_IP ($interface): $ip_addr."
            fi
            break
        fi
    done < <(list_files /sys/class/net/ -type l | sed '/lo/d')
}

# Partition and format functions.
# Intended to be used in live installed mode.

# Get list of disks. Like 'sda\nsda1\nsdb'
# Loop devices are excluded.
function disk_list_get() {
    lsblk -nr -o NAME "$@" | sed -e '/loop[0-10]/d'
}
export -f disk_list_get

# Get root of disk. Example: in: /dev/sda1, out: /dev/sda
function disk_root_get() {
    lsblk --noheadings --output pkname "$1" 2>/dev/null || echo "$1"
}
export -f disk_root_get

# Auto partition. Pretty silly way.
# If bios, then one partition.
# If uefi, then two partition (boot 512M, root)
# Example: partition_auto uefi /dev/sda
function partition_auto() {
    local bootloader_type="$1" part_root="$2"
    if [[ $bootloader_type == "uefi" ]]; then
        echo -e "label: gpt\n ,512M,U\n,,L" | sfdisk "/dev/$part_root"
        export PART_BOOT PART_ROOT
        PART_BOOT="$(disk_list_get /dev/"$part_root" | sed '2q;d')"
        PART_ROOT="$(disk_list_get /dev/"$part_root" | sed '3q;d')"
    else
        echo -e "label: dos\n ,,L" | sfdisk "/dev/$part_root"
        export PART_BOOT PART_ROOT
        PART_BOOT="$part_root"
        PART_ROOT="$(disk_list_get "/dev/$part_root" | sed '2q;d')"
    fi
    echo -e "PART_BOOT=\"$PART_BOOT\" PART_ROOT=\"$PART_ROOT\""
    command_exists mdev && mdev -s &>/dev/null # Add symbol devices. It is bug of mdev
}
export -f partition_auto

# Format and mount 
function format_and_mount() {
    local bootloader_type="$1" part_root="$2" part_boot="$3" fstype="${4:-ext4}" mount_dir=${5:-/mnt/mnt}
    msg_print note "$M_FORMAT $part_root..."
    "mkfs.$fstype" -L "Linux" -F "$part_root"
    msg_print note "$M_MOUNT $part_root..."
    mount -t "$fstype" "$part_root" "$mount_dir"
    if [[ $bootloader_type == "uefi" ]]; then
        if [[ $(findmnt -Recvruno FSTYPE "$part_boot") != "vfat" ]]; then
            msg_print note "$M_FORMAT $part_boot..."
            mkfs.vfat -F32 -n 'BOOT' "$part_boot"
        fi
        msg_print note "$M_MOUNT $part_boot..."
        mkdir -p "$mount_dir/boot"
        mount -t vfat "$part_boot" "$mount_dir/boot"
    else
        # shellcheck disable=SC2034
        export bootloader_bios_place=$part_boot
    fi
}
export -f format_and_mount

function umount_partitions() {
    local bootloader_type="${1:-BOOTLOADER_TYPE_DEFAULT}" mount_dir=${2:-/mnt/mnt}
    [[ $bootloader_type == "uefi" ]] && try_exec 0 umount "$mount_dir/boot"
    try_exec 0 umount "$mount_dir"
}
export -f umount_partitions