linux_install (auto profile)
============================

This project has auto mode. It is named "auto profile", because all automation is being written in profile file.
It can be generated using `profile_gen.sh`, then edited in text editor, then used for automatic installation.

### Common information:
* For now, there is no check for correct options in profile.
* There are some functions, that can be used in auto profile. They are described in next section (installer functions).
* These profile are bash scripts, so they fully support all bash syntax and binaries (like wget, grep, etc).

### Installer functions:
* `interface_setup_dhcp` - Setup DHCP on chosen interface. Example: `interface_setup_dhcp eth0`.
* `interface_setup_static` - Setup static address on chosen interface. Example: `interface_setup_static eth0 ip_client ip_mask gateway ip_dns`.
* `interface_con_wlan` - Setup network interface using chosen method. Example: `interface_con_wlan wlan0 SSID SSID_PASS dhcp` OR `interface_con_wlan wlan0 SSID SSID_PASS static ip_client ip_mask gateway ip_dns`.
* `partition_auto` - Auto partition disk, then set and print `PART_BOOT` and `PART_ROOT`. It will destroy all data on it. Work for both BIOS (1 partition) and UEFI (2 partitions: EFI 512M partition and root partition). Example: `partition_auto bios sda` OR `partition_auto uefi nvme0n1`
* `format_and_mount` - Format and mount chosen disk. For BIOS, it will set `bootloader_bios_place`. Example: `format_and_mount uefi /dev/sda2 /dev/sda1` OR `format_and_mount bios /dev/sda1 /dev/sda`.
* `do_end_action` - Do end action. Used at the end of work. Example: `do_end_action 0` (will reboot) OR `do_end_action 1` (will poweroff) OR `do_end_action 3` (will wall to console).

### Structure:
* It is recommended to virtually divide profile to two parts: actions, with formatting and mounting filesystems, and set of parameters, after which system will be installed.
* Keep in mind that install_sys.sh only installs rootfs. It does not do partition or mount filesystems, but make system bootable.