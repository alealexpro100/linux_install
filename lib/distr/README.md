linux_install (distros)
=======================

You can add you own distro to this directory. It is called 'distro implementation'. There are some notes about making it.

### Notes:
* It is necessary to look for an example distribution. See `alpine`, simplient implementation.
* Debian distro file can be used also for ubuntu or someting else deb-based. See `astra` implementation.
* Every distro implementation guarantees that an installed (from live installer) system will be bootable, able to connect to network and usable throw openssh (if chosen). Keep in mind that.
* Use `common_options.sh` file and place rootfs unpacker to `./bin` directory. Note that rootfs unpacker by default uses only mirror with needed packages.