linux_install (distros)
=======================

You can add you own distro to this directory. It is called 'distro implementation'. There are some notes about making it.

### Structure
* `rootfs` - directory with files, that will be placed after in `common_actions_1.sh` (after bootstrap, but before chroot).
* `distr_actions.sh` - executed while running `install_sys.sh`. It is main installation part of specific distro.
* `distr_options.sh` - executed while running `profile_gen.sh`. Asks options of specific distro.

### Notes
* It is necessary to look for an example distribution. See `alpine`, simpliest implementation.
* Debian implementation can be used also for ubuntu or other deb-based OS. See `astra` implementation.
* Every distro implementation guarantees that an installed system (using live installer) will be bootable, able to connect to network and usable through SSH (if chosen).
* Use `common_options.sh` file and place rootfs unpacker to `./bin` directory. Every rootfs unpacker have to use only mirror with needed packages, not bootstrap file.