#!/bin/bash

set -e

#Import some libraries.
# shellcheck disable=SC1091
source ./linux_install/lib/alexpro100_lib.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_var_op.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_ui.sh

# shellcheck disable=SC2046
IFS=' ' read -ra kernel_cmdline < /proc/cmdline
for option in ${kernel_cmdline[*]}; do
    case $option in
        AUTO_PROFILE=*|REBOOT_AFTER=*) export "${option?}";;
    esac
done

function list_disks_get() {
    lsblk -nr -o NAME "$@" | sed -e '/loop[0-10]/d'
}

# shellcheck disable=SC1090
source "./linux_install/lib/msg/${LANG_INSTALLER:-en}.sh"

msg_print note "$M_WELCOME"

if [[ -n "$AUTO_PROFILE" ]]; then
    msg_print note "$M_MODE_AUTO"
    if ! check_online; then
        msg_print warning "$M_HOST_OFFLINE"
        for interface in $(list_files "/sys/class/net/" -type l | sed '/lo/d'); do
            msg_print note "$M_NET_TRY_DHCP $interface..."
            try_exec 0 ifconfig "$interface" 0.0.0.0
            timeout 10 udhcpc -i "$interface" -f -q || msg_print error "$M_NET_DHCP_FAIL"
        done
    fi
    if wget -O /tmp/auto_profile.sh "$AUTO_PROFILE" && ./linux_install/install_sys.sh /tmp/auto_profile.sh; then
        [[ "$REBOOT_AFTER" == 0 ]] || reboot
        bash
    else
        msg_print error "$M_MODE_AUTO_FAIL"
    fi
fi

msg_print note "$M_MODE_MANUAL"

gen_menu < <(list_files "./linux_install/lib/msg/" | sed "s|.sh||g")
read_param "" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER menu_var "${tmp_gen_menu[@]}"
# shellcheck disable=SC1090
source "./linux_install/lib/msg/$LANG_INSTALLER.sh"

while ! check_online; do
    msg_print warning "$M_HOST_OFFLINE"
    gen_menu < <(list_files "/sys/class/net/" -type l | sed '/lo/d')
    read_param "$M_NET_INTERFACE_DETECTED_LIST:\n" "$M_NET_INTERFACE_CHOOSE" "0" interface menu_var "${tmp_gen_menu[@]}"
    case $interface in
        wlan*)
            ip link set "$interface" up
            gen_menu < <(iwlist "$interface" scanning | awk -F ':' '/ESSID:/ {print $2;}' | sed 's/\"//g')
            read_param "$M_NET_WIFI_SCAN_RESULT:\n" "$M_NET_WIFI_SSID_CHOOSE" "" SSID menu_var "${tmp_gen_menu[@]}"
            iwconfig "$interface" essid "$SSID"
            read_param "$M_NET_WIFI_SSID_PASS $SSID.\n" "$M_PASS" "" SSID_PASS secret
            if wpa_passphrase "$SSID" "$SSID_PASS" > "/etc/wpa_supplicant/wpa_supplicant-$interface.conf"; then
                if wpa_supplicant -B -i "$interface" -c "/etc/wpa_supplicant/wpa_supplicant-$interface.conf"; then
                    timeout 10 udhcpc -i "$interface" -f -q || msg_print error "$M_NET_DHCP_FAIL"
                fi
            else
                msg_print error "$(cat "/etc/wpa_supplicant/wpa_supplicant-$interface.conf")"
            fi
        ;;
        eth*)
            gen_menu < <(echo -e "dhcp\nmanual")
            read_param "" "$M_NET_ETH_METHOD" "dhcp" IP_METHOD menu_var "${tmp_gen_menu[@]}"
            case $IP_METHOD in
                dhcp)
                    msg_print note "$M_NET_TRY_DHCP $interface..."
                    try_exec 0 ifconfig "$interface" 0.0.0.0
                    timeout 10 udhcpc -i "$interface" -f -q || msg_print error "$M_NET_DHCP_FAIL"
                ;;
                manual)
                    #Not tested.
                    read_param "" "Client IP" "" IP_CLIENT text
                    read_param "" "(Optional) Netmask" "" IP_NETMASK text
                    read_param "" "(Optional) Gateway IP" "" IP_GATEWAY text_empty
                    read_param "" "(Optional) DNS Server" "" IP_DNS text_empty
                    if ifconfig "$interface" "$IP_CLIENT" "$([[ -n "$IP_NETMASK" ]] && echo "netmask \"$IP_NETMASK\"")"; then
                        [[ -z "$IP_GATEWAY" ]] && ip route add 0.0.0.0/0 via "$IP_GATEWAY" dev "$interface"
		            fi
		            [[ -n $IP_DNS ]] && echo "nameserver $IP_DNS" >> /etc/resolv.conf
                ;;
            esac
        ;;
        *)
            msg_print error "Incorrect interface $interface!"
        ;;
    esac
done
msg_print note "$M_HOST_ONLINE"

gen_menu < <(echo -e "install\nconsole")
read_param "" "$M_WORK_MODE" "install" WORK_MODE menu_var "${tmp_gen_menu[@]}"
if [[ $WORK_MODE == "install" ]]; then
    #Partition work. Here we format and mount needed partion(s).
    PART_BOOT="" PART_ROOT=""
    while [[ -z $PART_BOOT || -z "$PART_ROOT" ]]; do
        read_param "" "$M_PART" "" PART_DO no_or_yes
        print_param note "$M_PART_D_M:\n$(lsblk | sed -e '/loop[0-10]/d')"
        if [[ $PART_DO == "1" ]]; then
            gen_menu < <(list_disks_get -d)
            read_param "" "$M_PART_D" "" PART_ROOT menu_var "${tmp_gen_menu[@]}"
            cfdisk -z "/dev/$PART_ROOT"
            partprobe "/dev/$PART_ROOT"
            mdev -s &>/dev/null
        else
            gen_menu < <(list_disks_get)
            read_param "$M_PART_I_M\n" "$M_PART_P" "" PART_ROOT menu_var "${tmp_gen_menu[@]}"
            if [[ -d /sys/firmware/efi/efivars ]]; then
                BOOTLOADER_TYPE_DEFAULT=uefi
                gen_menu < <(list_disks_get)
                read_param "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT.\n" "$M_BOOTLOADER_PATH" "" PART_BOOT menu_var "${tmp_gen_menu[@]}"
                [[ $(findmnt -Recvruno FSTYPE "$PART_BOOT") != "vfat" ]] && print_param warning "Partition $PART_BOOT will be formatted to vfat filesystem." 
            else
                BOOTLOADER_TYPE_DEFAULT=bios
                gen_menu < <(list_disks_get)
                read_param "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT.\n" "$M_BOOTLOADER_PATH" "$(lsblk --noheadings --output pkname "/dev/$PART_ROOT" 2>/dev/null || echo "$PART_ROOT")" PART_BOOT menu_var "${tmp_gen_menu[@]}"
            fi
            read_param "" "$M_CHANGE_DO" "" PART_DO no_or_yes
            if [[ $PART_DO == "1" ]]; then
                PART_ROOT="/dev/$PART_ROOT" PART_BOOT="/dev/$PART_BOOT"
                msg_print note "$M_FORMAT $PART_ROOT..."
                mkfs.ext4 -L "Linux" -F "$PART_ROOT"
                msg_print note "$M_MOUNT $PART_ROOT..."
                mount -t ext4 "$PART_ROOT" /mnt/mnt
                if [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]]; then
                    if [[ $(findmnt -Recvruno FSTYPE "$PART_BOOT") != "vfat" ]]; then
                        msg_print note "$M_FORMAT $PART_BOOT..."
                        mkfs.vfat -F32 -n 'BOOT' "$PART_BOOT"
                    fi
                    msg_print note "$M_MOUNT $PART_BOOT..."
                    mkdir -p /mnt/mnt/boot
                    mount -t vfat "$PART_BOOT" /mnt/mnt/boot
                else
                    # shellcheck disable=SC2034
                    export bootloader_bios_place=$PART_BOOT
                fi
            else
                PART_BOOT="" PART_ROOT=""
            fi
        fi
    done
    msg_print note "$M_CHANGE_C"
    gen_menu < <(echo -e "dialog\ncli")
    read_param "" "$M_ECHO_MODE" "dialog" ECHO_MODE menu_var "${tmp_gen_menu[@]}"
    cd ./linux_install
    LIVE_MODE=1 ./profile_gen.sh
    ./install_sys.sh /tmp/last_gen.sh
    [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]] && umount /mnt/mnt/boot
    umount -l /mnt/mnt
    gen_menu < <(echo -e "$M_END_OPTION_REBOOT\n$M_END_OPTION_POWEROFF\n$M_END_OPTION_CONSOLE")
    read_param "" "$M_ECHO_MODE" "0" end_action menu "${tmp_gen_menu[@]}"
    case $end_action in
        0) msg_print note "Rebooting..."; reboot;;
        1) msg_print note "Powering off..."; poweroff;;
        2) msg_print note "$M_REBOOT_M";;
    esac
else
    msg_print note "$M_MODE_CONSOLE_M"
fi