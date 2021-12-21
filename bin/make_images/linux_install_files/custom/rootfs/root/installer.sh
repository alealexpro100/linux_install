#!/bin/bash

set -e

# shellcheck disable=SC2034
ALEXPRO100_LIB_DEBUG=0

#Import some libraries.
# shellcheck disable=SC1091
source ./linux_install/lib/alexpro100_lib.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_var_op.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_ui.sh
# shellcheck disable=SC1090
source "./linux_install/lib/msg/${LANG_INSTALLER:-en}.sh"

# shellcheck disable=SC2046
IFS=' ' read -ra kernel_cmdline < /proc/cmdline
for option in "${kernel_cmdline[@]}"; do
    case $option in
        AUTO_PROFILE=*) export "${option?}";;
    esac
done

# These functions are designed for using not only in installer, but in automatic profiles.

function disk_list_get() {
    lsblk -nr -o NAME "$@" | sed -e '/loop[0-10]/d'
}
export -f disk_list_get

function disk_root_get() {
    lsblk --noheadings --output pkname "$1" 2>/dev/null || echo "$1"
}
export -f disk_root_get

function interface_setup_dhcp() {
    msg_print note "$M_NET_TRY_DHCP $1..."
    try_exec 0 ifconfig "$1" 0.0.0.0
    timeout 10 udhcpc -i "$1" -f -q || msg_print error "$M_NET_DHCP_FAIL"
}
export -f interface_setup_dhcp

function interface_setup_static() {
    local interface="$1" ip_client="$2" ip_netmask="$3" ip_gateway="$4" ip_dns="$5"
    if ifconfig "$interface" "$ip_client" netmask "$ip_netmask"; then
        [[ -z "$ip_gateway" ]] || ip route add 0.0.0.0/0 via "$ip_gateway" dev "$interface"
    fi
    [[ -n $ip_dns ]] && echo "nameserver $ip_dns" >> /etc/resolv.conf
}
export -f interface_setup_static

function interface_con_wlan() {
    local interface="$1" ssid="$2" ssid_pass="$3" ip_method="${4:-dhcp}"  ip_client="$5" ip_netmask="$6" ip_gateway="$7" ip_dns="$8"
    try_exec 0 ip link set "$interface" up
    iwconfig "$interface" essid "$ssid"
    if wpa_passphrase "$ssid" "$ssid_pass" > "/etc/wpa_supplicant/wpa_supplicant-$interface.conf"; then
        if wpa_supplicant -B -i "$interface" -c "/etc/wpa_supplicant/wpa_supplicant-$interface.conf"; then
            case $ip_method in
                auto|dhcp) interface_setup_dhcp "$interface";;
                static) interface_setup_static "$interface" "$ip_client" "$ip_netmask" "$ip_gateway" "$ip_dns";;
                *) return_err "Incorrect paramater ip_method!"
            esac
        fi
    else
        msg_print error "$(cat "/etc/wpa_supplicant/wpa_supplicant-$interface.conf")"
    fi
}
export -f interface_con_wlan

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
    mdev -s &>/dev/null # Add symbol devices.
}
export -f partition_auto

function format_and_mount() {
    local bootloader_type="$1" part_root="$2" part_boot="$3"
    msg_print note "$M_FORMAT $part_root..."
    mkfs.ext4 -L "Linux" -F "$part_root"
    msg_print note "$M_MOUNT $part_root..."
    mount -t ext4 "$part_root" /mnt/mnt
    if [[ $bootloader_type == "uefi" ]]; then
        if [[ $(findmnt -Recvruno FSTYPE "$part_boot") != "vfat" ]]; then
            msg_print note "$M_FORMAT $part_boot..."
            mkfs.vfat -F32 -n 'BOOT' "$part_boot"
        fi
        msg_print note "$M_MOUNT $part_boot..."
        mkdir -p /mnt/mnt/boot
        mount -t vfat "$part_boot" /mnt/mnt/boot
    else
        # shellcheck disable=SC2034
        export bootloader_bios_place=$part_boot
    fi
}
export -f format_and_mount

function umount_partitions() {
    [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]] && umount /mnt/mnt/boot
    umount -l /mnt/mnt
}
export -f umount_partitions

function do_end_action() {
    case $1 in
        0) msg_print note "Rebooting..."; reboot;;
        1) msg_print note "Powering off..."; poweroff;;
        2) msg_print note "$M_REBOOT_M"; bash;;
    esac
    exit 0
}
export -f do_end_action

if [[ -d /sys/firmware/efi/efivars ]]; then
    export BOOTLOADER_TYPE_DEFAULT=uefi
else
    export BOOTLOADER_TYPE_DEFAULT=bios
fi

msg_print note "$M_WELCOME $(cat ./linux_install/version_install)"

if [[ -n "$AUTO_PROFILE" ]]; then
    msg_print note "$M_MODE_AUTO"
    if is_url "$AUTO_PROFILE"; then
        if ! check_online; then
            msg_print warning "$M_HOST_OFFLINE"
            for interface in $(list_files "/sys/class/net/" -type l | sed '/lo/d'); do
                interface_setup_dhcp "$interface"
            done
        fi
        wget -O /tmp/auto_profile.sh "$AUTO_PROFILE" || return_err "Couldn't download $AUTO_PROFILE."
    else
        cp -a "$AUTO_PROFILE" /tmp/auto_profile.sh || return_err "Couldn't copy $AUTO_PROFILE."
    fi
    if ./linux_install/install_sys.sh /tmp/auto_profile.sh; then
        umount_partitions
    else
        return_err "$M_MODE_AUTO_FAIL"
    fi
    bash
fi

msg_print note "$M_MODE_MANUAL"

read_param "" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER menu_var "$(gen_menu < <(list_files "./linux_install/lib/msg/" | sed "s|.sh||g"))"
# shellcheck disable=SC1090
source "./linux_install/lib/msg/$LANG_INSTALLER.sh"

while ! check_online; do
    msg_print warning "$M_HOST_OFFLINE"
    read_param "$M_NET_INTERFACE_DETECTED_LIST:\n" "$M_NET_INTERFACE_CHOOSE" "0" INTERFACE menu_var "$(gen_menu < <(list_files "/sys/class/net/" -type l | sed '/lo/d'))"
    #shellcheck disable=SC2153
    case $INTERFACE in
        wlan*)
            ip link set "$INTERFACE" up
            read_param "$M_NET_WIFI_SCAN_RESULT:\n" "$M_NET_WIFI_SSID_CHOOSE" "" SSID menu_var "$(gen_menu < <(iwlist "$INTERFACE" scanning | awk -F ':' '/ESSID:/ {print $2;}' | sed 's/\"//g'))"
            read_param "$M_NET_WIFI_SSID_PASS $SSID.\n" "$M_PASS" "" SSID_PASS secret
            interface_con_wlan "$INTERFACE" "$SSID" "$SSID_PASS"
        ;;
        eth*|eno*|rename*)
            read_param "" "$M_NET_ETH_METHOD" "dhcp" IP_METHOD menu_var "$(gen_menu < <(echo -e "dhcp\nmanual"))"
            case $IP_METHOD in
                dhcp)
                    interface_setup_dhcp "$INTERFACE"
                ;;
                manual)
                    read_param "" "Client IP" "" IP_CLIENT text
                    read_param "" "(Optional) Netmask" "" IP_NETMASK text
                    read_param "" "(Optional) Gateway IP" "" IP_GATEWAY text_empty
                    read_param "" "(Optional) DNS Server" "" IP_DNS text_empty
                    interface_setup_static "$INTERFACE" "$IP_CLIENT" "$IP_NETMASK" "$IP_GATEWAY" "$IP_DNS"
                ;;
            esac
        ;;
        *)
            msg_print error "Incorrect interface $interface!"
        ;;
    esac
done
msg_print note "$M_HOST_ONLINE"

read_param "" "$M_WORK_MODE" "install" WORK_MODE menu_var "$(gen_menu < <(echo -e "install\nconsole"))"
if [[ $WORK_MODE == "install" ]]; then
    #Partition work. Here we format and mount needed partion(s).
    PART_BOOT="" PART_ROOT="" PART_DO=""
    while [[ $PART_DO != "0" ]]; do
        read_param "" "$M_PART" "" PART_DO no_or_yes
        print_param note "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT.\n$M_PART_D_M:\n$(lsblk | sed -e '/loop[0-10]/d')"
        if [[ $PART_DO == "1" ]]; then
            msg_print warning "$M_PART_WARN"
            read_param "" "$M_PART_D" '0' PART_ROOT menu_var "$(gen_menu < <(disk_list_get -d))"
            read_param "" "$M_PART_MODE" "auto" PART_MODE menu_var "$(gen_menu < <(echo -e "auto\nmanual"))"
            if [[ $PART_MODE == "auto" ]]; then
                partition_auto "$BOOTLOADER_TYPE_DEFAULT" "$PART_ROOT"
                PART_DO="0"
            else
                cfdisk -z "/dev/$PART_ROOT"
                mdev -s &>/dev/null # Add symbol devices.
            fi
        fi
        if [[ $PART_MODE != "auto" ]]; then
            read_param "$M_PART_I_M\n" "$M_PART_P" "" PART_ROOT menu_var "$(gen_menu < <(disk_list_get))"
            if [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]]; then
                read_param "" "$M_BOOTLOADER_PATH" "$(disk_root_get "/dev/$PART_ROOT" | sed '2q;d')" PART_BOOT menu_var "$(gen_menu < <(disk_list_get))"
                [[ $(findmnt -Recvruno FSTYPE "$PART_BOOT") != "vfat" ]] && print_param warning "Partition $PART_BOOT will be formatted to vfat filesystem." 
            else
                read_param "" "$M_BOOTLOADER_PATH" "$(disk_root_get "/dev/$PART_ROOT")" PART_BOOT menu_var "$(gen_menu < <(disk_list_get))"
            fi
            PART_DO="0"
        fi
    done
    format_and_mount $BOOTLOADER_TYPE_DEFAULT "/dev/$PART_ROOT" "/dev/$PART_BOOT"
    read_param "" "$M_ECHO_MODE" "dialog" ECHO_MODE menu_var "$(gen_menu < <(echo -e "dialog\ncli"))"
    cd ./linux_install
    while [[ ! -f /tmp/last_gen.sh ]]; do
        LIVE_MODE=1 ./profile_gen.sh
    done
    ./install_sys.sh /tmp/last_gen.sh
    umount_partitions
    read_param "$M_CHANGE_C" "" "0" END_ACTION menu "$(gen_menu < <(echo -e "$M_END_OPTION_REBOOT\n$M_END_OPTION_POWEROFF\n$M_END_OPTION_CONSOLE"))"
    do_end_action "$END_ACTION"
else
    msg_print note "$M_MODE_CONSOLE_M"
fi