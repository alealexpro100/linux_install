#!/bin/bash

set -e

#Import some libraries.
# shellcheck disable=SC1091
source ./linux_install/bin/alexpro100_lib.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_var_op.sh
# shellcheck disable=SC1091
source ./linux_install/lib/common/lib_ui.sh

function list_disks_get() {
    lsblk -nr -o NAME "$@" | sed -e '/loop[0-10]/d' | tr '\n' ',' | sed -e 's/,$//'
}

msg_print note "Welcome to ALEXPRO100 Linux install!"

#Language support.
msg_dir="./linux_install/lib/msg/"
msg_file_list="$(list_files "$msg_dir" | sed "s|.sh||g")"
# shellcheck disable=SC1090
source "$msg_dir/${LANG_INSTALLER:-en}.sh"
read_param "$M_MSG_M: \n$msg_file_list\n" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER text_check "$(echo "$msg_file_list" | tr '\n' ',')"
# shellcheck disable=SC1090
source "$msg_dir/$LANG_INSTALLER.sh"

while ! check_online; do
    msg_print error "Host is offline!"
    msg_print warning "You need to connect to network manually."
    NETWORK_INTERFACES="$(list_files "/sys/class/net/" -type l | sed '/lo/d')"
    msg_print note "Detected network devices: \n$NETWORK_INTERFACES"
    read_param "" "Choose interface to setup" "$(echo -e "$NETWORK_INTERFACES" | head -1)" INTERFACE text_check "$(echo -e "$NETWORK_INTERFACES" | tr '\n' ',')"
    case $INTERFACE in
        wlan*)
            ip link set "$INTERFACE" up
            SSID_LIST="$(iwlist "$INTERFACE" scanning | awk -F ':' '/ESSID:/ {print $2;}' | sed 's/\"//g')"
            msg_print note "Scan result: \n$SSID_LIST"
            read_param "" "Choose SSID" "" SSID text_check "$(echo -e "$SSID_LIST" | tr '\n' ',')"
            iwconfig "$INTERFACE" essid "$SSID"
            read_param "Enter password for $SSID.\n" "Password" "" SSID_PASS secret
            if wpa_passphrase "$SSID" "$SSID_PASS" > "/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"; then
                if wpa_supplicant -B -i "$INTERFACE" -c "/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"; then
                    timeout 10 udhcpc -i "$INTERFACE" -f -q || msg_print error "Failed to setup dhcp."
                fi
            else
                msg_print error "$(cat "/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf")"
            fi
        ;;
        eth*)
            read_param "" "Choose method: " "dhcp" IP_METHOD text_check "dhcp,manual"
            case $IP_METHOD in
                dhcp)
                    msg_print note "Trying to setup dhcp on interface $INTERFACE..."
                    try_exec 0 ifconfig "$INTERFACE" 0.0.0.0
                    timeout 10 udhcpc -i "$INTERFACE" -f -q || msg_print error "Failed to setup dhcp."
                ;;
                manual)
                    #Not tested.
                    read_param "" "Client IP" "" IP_CLIENT text
                    read_param "" "Netmask" "" IP_NETMASK text
                    read_param "" "(Optional) Gateway IP" "" IP_GATEWAY text_empty
                    read_param "" "(Optional) DNS Server" "" IP_DNS text_empty
                    if ifconfig "$INTERFACE" "$IP_CLIENT" netmask "$IP_NETMASK"; then
                        [[ -z "$IP_GATEWAY" ]] && ip route add 0.0.0.0/0 via "$IP_GATEWAY" dev "$INTERFACE"
		            fi
		            [[ -n $IP_DNS ]] && echo "nameserver $IP_DNS" >> /etc/resolv.conf
                ;;
            esac
        ;;
        *)
            msg_print error "Incorrect interface $INTERFACE!"
        ;;
    esac
done
msg_print note "Host is online. Proceeding to next steps."

read_param "$M_WORK_MODE_M\n" "$M_WORK_MODE (install/console)" "install" WORK_MODE text_check install,console
if [[ $WORK_MODE == "install" ]]; then
    mkdir -p /mnt/mnt >> /dev/null
    #Partition work. Here we format and mount needed partion(s).
    PART_BOOT="" PART_ROOT=""
    while [[ -z $PART_BOOT || -z "$PART_ROOT" ]]; do
        read_param "" "$M_PART" "" PART_DO no_or_yes
        msg_print note "$M_PART_D_M:\n$(lsblk | sed -e '/loop[0-10]/d')"
        if [[ $PART_DO == "1" ]]; then
            read_param "" "$M_PART_D" "" PART_ROOT text_check "$(list_disks_get -d)"
            cfdisk -z "/dev/$PART_ROOT"
            partprobe "/dev/$PART_ROOT"
        else
            read_param "$M_PART_I_M\n" "$M_PART_P" "" PART_ROOT text_check "$(list_disks_get)"
            if [[ -d /sys/firmware/efi/efivars ]]; then
                BOOTLOADER_TYPE_DEFAULT=uefi
                msg_print note "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT."
                read_param "$M_PART_B_M\n" "$M_PART_P" "" PART_BOOT text_check "$(list_disks_get)"
                [[ $(findmnt -Recvruno FSTYPE "$PART_BOOT") != "vfat" ]] && msg_print warning "Partition $PART_BOOT is NOT a vfat filesystem." 
            else
                BOOTLOADER_TYPE_DEFAULT=bios
                msg_print note "$M_BOOTLOADER_TYPE: $BOOTLOADER_TYPE_DEFAULT."
                read_param "" "$M_BOOTLOADER_PATH" "/dev/$(lsblk --noheadings --output pkname "$PART_ROOT")" PART_BOOT text_check "$(list_disks_get)"
            fi
            read_param "" "$M_CHANGE_DO" "" PART_DO no_or_yes
            if [[ $PART_DO == "1" ]]; then
                PART_ROOT="/dev/$PART_ROOT" PART_BOOT="/dev/$PART_BOOT"
                msg_print note "$M_FORMAT $PART_ROOT..."
                mkfs.ext4 -L "Linux" "$PART_ROOT"
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
                    bootloader_bios_place=$PART_BOOT
                fi
            else
                PART_BOOT="" PART_ROOT=""
            fi
        fi
    done
    msg_print note "$M_CHANGE_C"
    read_param "$M_ECHO_MODE_M\n" "$M_ECHO_MODE (dialog/cli)" "dialog" ECHO_MODE text_check dialog,cli
    cd ./linux_install
    LIVE_MODE=1 ./profile_gen.sh
    ./install_sys.sh /tmp/last_gen.sh
    [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]] && umount /mnt/mnt/boot
    umount /mnt/mnt
    msg_print note "Complete! To reboot, type \"reboot\""
else
    msg_print note "To run installer, type ./linux_install/profile_gen.sh and then ./linux_install/install_sys.sh"
fi