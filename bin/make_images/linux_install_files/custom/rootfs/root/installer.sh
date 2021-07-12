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
msg_file_list="$(find "$msg_dir" | sort | sed "s|$msg_dir||g;s|.sh||g;/^$/d")"
# shellcheck disable=SC1090
source "$msg_dir/${LANG_INSTALLER:-en}.sh"
read_param "$M_MSG_M: \n$msg_file_list\n" "$M_MSG_OPT" "${LANG_INSTALLER:-en}" LANG_INSTALLER text_check "$(echo "$msg_file_list" | tr '\n' ',')"
# shellcheck disable=SC1090
source "$msg_dir/$LANG_INSTALLER.sh"
read_param "$M_WORK_MODE_M\n" "$M_WORK_MODE (install/console)" "install" WORK_MODE text_check install,console
if [[ $WORK_MODE == "install" ]]; then
    cd ./linux_install
    #Partition work.
    PART_BOOT="" PART_ROOT=""
    while [[ -z $PART_BOOT || -z "$PART_ROOT" ]]; do
        read_param "" "$M_PART" "" PART_DO no_or_yes
        msg_print note "$M_PART_D_M:\n$(lsblk | sed -e '/loop[0-10]/d')"
        if [[ $PART_DO == "1" ]]; then
            read_param "" "$M_PART_D" "" PART_ROOT text_check "$(list_disks_get -d)"
            cfdisk -z "/dev/$PART_ROOT"
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
    LIVE_MODE=1 ./profile_gen.sh
    ./install_sys.sh /tmp/last_gen.sh
    [[ $BOOTLOADER_TYPE_DEFAULT == "uefi" ]] && umount /mnt/mnt/boot
    umount /mnt/mnt
    msg_print note "Complete! To reboot, type \"reboot\""
fi

msg_print warning "To run installer, type ./linux_install/profile_gen.sh and then ./linux_install/install_sys.sh"