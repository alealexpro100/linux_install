linux_install (auto profile)
============================

This project has auto mode. It is named "auto profile", because all automation is being written in profile file.
Also "live auto profile" determines automatic profile, used in live installer.
It can be generated using `profile_gen.sh`, then edited in text editor, then used for automatic installation.

### Common information

* For now, there is no check for correct options in profile.
* If you want to now, what steps is done in live auto profile mode, please check [**steps for live auto profile**](#steps-of-live-auto-profile) section.
* Also, the are some internal variables and functions. See them in [**installer variables**](#installer-variables) and [**installer functions**](#installer-functions) sections.
* These profile are bash scripts, so they fully support all bash syntax and binaries (like wget, grep, etc).
* To build your own live auto profile, see [**building live auto profile**](#building-live-auto-profile) section.

### Steps of live auto profile

* Setup network for getting packages.
* Do partition, format and mount them.
* Install system with defined options (`add_var`).
* (If exists) Copy files from custom `rootfs` and execute `custom_script.sh`.
* Execute `profile_end_action`.

### Installer functions

* `check_online` - Return if host is online (does NOT check internet connection, only local network). Returns **0** if host is online, and **1** if not.
* `interface_setup_dhcp` - Setup DHCP on chosen interface. Example: `interface_setup_dhcp eth0`.
* `interface_setup_static` - Setup static address on chosen interface. Example: `interface_setup_static eth0 ip_client ip_mask gateway ip_dns`.
* `interface_con_wlan` - Setup network interface using chosen method. Example: `interface_con_wlan wlan0 SSID SSID_PASS dhcp` OR `interface_con_wlan wlan0 SSID SSID_PASS static ip_client ip_mask gateway ip_dns`.
* `partition_auto` - Auto partition disk, then set and print `PART_BOOT` and `PART_ROOT`. It will destroy all data on it. Work for both BIOS (1 partition) and UEFI (2 partitions: EFI 512M partition and root partition). Example: `partition_auto bios sda` OR `partition_auto uefi nvme0n1`
* `format_and_mount` - Format and mount chosen disk. For BIOS, it will set `bootloader_bios_place`. Example: `format_and_mount uefi /dev/sda2 /dev/sda1` OR `format_and_mount bios /dev/sda1 /dev/sda`.
* `do_end_action` - Do end action. Used at the end of work. Example: `do_end_action 0` (will reboot) OR `do_end_action 1` (will poweroff) OR `do_end_action 3` (will wall to console).

### Installer variables

* **BOOTLOADER_TYPE_DEFAULT** - Determines default bootloader type. Sets automatically to `uefi` or `bios`, depending on system.
* **END_ACTION** - Points to end action. Options: `0` (will reboot) OR `1` (will power off) OR `3` (will fall to console). Default: `3`.

### Notes

* It is strongly recommended to see example auto live profile: [`./auto_configs/example_auto_profile.sh`](./example_auto_profile.sh).
* It is recommended to virtually divide profile to two parts: actions, with formatting and mounting filesystems, and set of parameters, after which system will be installed.
* Keep in mind that `install_sys.sh` by default installs only rootfs. It does not do partition or mount filesystems, but make system bootable.

### Building live auto profile

* First of all, generate auto profile using `profile_gen.sh`. We will edit soon.
* Determine how you will connect network to client machine and where system will be installed.
* Using previous section, add necessary lines to your auto live profile.
* Do not forget to write `profile_end_action` function in profile.
