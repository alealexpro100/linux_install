linux_install (development notes)
=================================

## Why only root for install_sys.sh?

Due to user permissions limitations, even with utilities like `bwrap` or `proot`, it is not possible to use `install_sys.sh` without root permissions.

More detailed limitations:

* Alpine package manager (apk) uses chown functions which cannot be modified using `fakeroot`.
* Proot does not correctly support recursive mounts, so it is not possible to use for arch-like installations (pacman).

## Why there are no trap functions?

Original creator does not want to use them due its hard-to-control nature. Perhaps they will be used.

## Too unstable

Issues are always opened. Author simply forgets about possible abnormal situations.

## Why it supports only 5 distributions?

Most distributions are either deb-based or rpm-based. First type is released, second is WIP.
There are 3 additional original distributions supported too.
Deb-based distributions supported, see `astralinux` install implementation.
