#!/bin/bash

set -e

# shellcheck disable=SC2034
ALEXPRO100_LIB_DEBUG=0

# shellcheck disable=SC2046
IFS=' ' read -ra kernel_cmdline < /proc/cmdline
for option in "${kernel_cmdline[@]}"; do
    case $option in
        AUTO_PROFILE=*|LANG_INSTALLER=*) export "${option?}";;
    esac
done

#Import some libraries.
# shellcheck disable=SC1091
source ./linux_install/lib/alexpro100_lib.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_sys.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_var_op.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_ui.sh
# shellcheck disable=SC1090
source "./linux_install/lib/msg/${LANG_INSTALLER:-en}.sh"

# These functions are designed for using not only in installer, but in automatic profiles.

function do_end_action() {
    umount_partitions
    case $1 in
        0) msg_print note "Rebooting..."; reboot;;
        1) msg_print note "Powering off..."; poweroff;;
        2) msg_print note "${M_REBOOT_M:-"Complete!"}"; bash;;
    esac
    exit 0
}
export -f do_end_action

if [[ -d /sys/firmware/efi/efivars ]]; then
    export BOOTLOADER_TYPE_DEFAULT=uefi
else
    export BOOTLOADER_TYPE_DEFAULT=bios
fi

print_param note "$M_WELCOME $(cat ./linux_install/version_install)"

if [[ -n "$AUTO_PROFILE" ]]; then
    print_param note "$M_MODE_AUTO"
    declare error_msg
    if is_url "$AUTO_PROFILE"; then
        if ! check_online; then
            print_param warning "$M_HOST_OFFLINE"
            for interface in $(list_files "/sys/class/net/" -type l | sed '/lo/d'); do
                interface_setup_dhcp "$interface"
            done
        fi
        wget -O /tmp/auto_profile.sh "$AUTO_PROFILE" || error_msg="Couldn't download $AUTO_PROFILE."
    else
        cp -a "$AUTO_PROFILE" /tmp/auto_profile.sh || error_msg="Couldn't copy $AUTO_PROFILE."
    fi
    if [[ -z $error_msg ]]; then
        ./linux_install/install_sys.sh /tmp/auto_profile.sh || error_msg="$M_MODE_AUTO_FAIL"
    fi
    [[ -z $error_msg ]] || print_param error "$error_msg"
    unset error_msg
fi

print_param note "$M_MODE_MANUAL"

while ! check_online; do
    print_param warning "$M_HOST_OFFLINE"
    read_param "$M_NET_INTERFACE_DETECTED_LIST:\n" "$M_NET_INTERFACE_CHOOSE" "0" INTERFACE menu_var "$(gen_menu < <(interfaces_get_list))"
    #shellcheck disable=SC2153
    case $INTERFACE in
        wlan*)
            ip link set "$INTERFACE" up
            read_param "$M_NET_WIFI_SCAN_RESULT:\n" "$M_NET_WIFI_SSID_CHOOSE" "" SSID menu_var "$(gen_menu < <(scan_for_networks $INTERFACE))"
            read_param "$M_NET_WIFI_SSID_PASS $SSID.\n" "$M_PASS" "" SSID_PASS secret
            try_exec 0 interface_con_wlan "$INTERFACE" "$SSID" "$SSID_PASS"
        ;;
        eth*|eno*|rename*)
            read_param "" "$M_NET_ETH_METHOD" "dhcp" IP_METHOD menu_var "$(gen_menu < <(echo -e "dhcp\nmanual"))"
            case $IP_METHOD in
                dhcp)
                    interface_setup_dhcp "$INTERFACE"
                ;;
                manual)
                    read_param "" "Client IP" "" IP_CLIENT text
                    read_param "" "Netmask" "" IP_NETMASK text
                    read_param "" "(Optional) Gateway IP" "" IP_GATEWAY text_empty
                    read_param "" "(Optional) DNS Server" "" IP_DNS text_empty
                    interface_setup_static "$INTERFACE" "$IP_CLIENT" "$IP_NETMASK" "$IP_GATEWAY" "$IP_DNS"
                ;;
            esac
        ;;
        *)
            print_param error "Incorrect interface $interface!"
        ;;
    esac
done
print_param note "$M_HOST_ONLINE"

interfaces_get_ip

print_param note "To connect use \`ssh -o \"UserKnownHostsFile /dev/null\" root@{given_ip}\`"

read_param "" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER menu_var "$(gen_menu < <(list_files "./linux_install/lib/msg/" | sed "s|.sh||g"))"
# shellcheck disable=SC1090
source "./linux_install/lib/msg/$LANG_INSTALLER.sh"

read_param "" "$M_WORK_MODE" "install" WORK_MODE menu_var "$(gen_menu < <(echo -e "install\nconsole"))"
if [[ $WORK_MODE == "install" ]]; then
    #Partition work. Here we format and mount needed partion(s).
    PART_BOOT="" PART_ROOT="" PART_DO=""
    while [[ $PART_DO != "0" ]]; do
        read_param "" "$M_PART" "" PART_DO no_or_yes
        print_param note "" "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT.\n$M_PART_D_M:\n$(lsblk | sed -e '/loop[0-10]/d')"
        if [[ $PART_DO == "1" ]]; then
            print_param warning "$M_PART_WARN"
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
    read_param "$M_CHANGE_C\n" "$M_ECHO_MODE" "dialog" ECHO_MODE menu_var "$(gen_menu < <(echo -e "dialog\ncli"))"
    cd ./linux_install
    while true; do
        LIVE_MODE=1 ./profile_gen.sh
        [[ ! -f /tmp/last_gen.sh ]] || break
    done
    ./install_sys.sh /tmp/last_gen.sh
    umount_partitions
    read_param "$M_CHANGE_C" "" "0" END_ACTION menu "$(gen_menu < <(echo -e "$M_END_OPTION_REBOOT\n$M_END_OPTION_POWEROFF\n$M_END_OPTION_CONSOLE"))"
    do_end_action "$END_ACTION"
else
    msg_print note "$M_MODE_CONSOLE_M"
fi