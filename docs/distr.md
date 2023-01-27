linux_install (distr directory)
===============================

You can add you own distro to this directory. It is called 'distro implementation'. There are some notes about making it.

## Structure

* `rootfs` - directory with files, that will be placed after in `common_actions_1.sh` (after bootstrap, but before chroot).
* `distr_actions.sh` - executed while running `install_sys.sh`. It is main installation part of specific distro.
* `distr_options.sh` - executed while running `profile_gen.sh`. Asks options of specific distro.

## Notes

* Debian implementation can be used also for ubuntu or other deb-based OS. See `astra` implementation.
* Every distro implementation guarantees that an installed system (using live installer) will be bootable, able to connect to network and usable through SSH (if chosen).
* Use `common_options.sh` file and place rootfs unpacker to `./bin` directory. Every rootfs unpacker have to use only mirror with needed packages, not bootstrap file.

## Distribution notes

### Alpine

This is the simplest implementation of OS install.
It is the most commented distro install implementation, so You should see it if you want to create your own implementation.
In fact live installer is based on this installer too, so it is really guaranteed to be correct.
And, as a result of being simple, there are no graphics or user-oriented options.

### Debian

Powerful installer for debian, which can be easily converted to be used to install other deb-based systems.
Astra install implementation is based on it. Use symbolic links to use files for your own implementation.
Supports various version of debian, starting with `stretch` version.

### Astra

Nothing interesting, beside it demonstrates how author tries to bypass bugs and un-fixable problems of AstraLinux.

### Archlinux

This is implementation for various arch-based distros, not only Archlinux.
It is oriented to be used by user, so it has variety of different options.

### Voidlinux

Looks like alpine install implementation.
It is pretty simple too.
Supports both glibc and musl revisions.
