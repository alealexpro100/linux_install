## Version 0.6.4

* Work on stability
* Add CI (fixes and image build)
* Work on docs
* Support boot from Ventoy

## Version 0.6.3

* Fix astralinux installation
* Redone build process
* Add cleanup after installation

## Version 0.6.2

* Move docs to its directory.
* Try to reduce size of new builds.
* Fix issues on busybox systems.
* More automation.

## Version 0.6.1

* More perfomance and stability for archlinux bootstrap.
* Less size of installer image.
* Updated documentation.

## Version 0.6.0

* Minor fixes.
* Dynamic dependency resolution for archlinux installation.

## Version 0.5.9

* Minor fixes.

## Version 0.5.8

* Interface fixes: added "back" button, clean up.
* Added support for astra installation.
* Added support for ssh server on every supported distribution.
* Reworked live installer: added function for auto profiles, added auto partition.
* Minor fixes: fixed alpine installation, made build simplier.

## Version 0.5.7

* Minor fixes (mostly interface).
* Added choose of type of kernel of Alpine.
* Start working on new arch-bootstrap script.

## Version 0.5.6

* Minor fixes.

## Version 0.5.5

* Added choice of reboot or power off in live installer.
* Interface fixes.
* Minor fixes.

## Version 0.5.4

* Fixed UEFI PXE live installer.
* Minor interface fixes.
* Minor fixes.

## Version 0.5.3

* Added flag AUTO_PROFILE.
* Reworked debian repo install.
* Added RPM bootstrap (testing).
* Interface fixes.

## Version 0.5.2

* Optimization of build.
* Minor fixes.

## Version 0.5.1

* More handy interface.
* Fixed disk partition.

## Version 0.5.0

* Made suitable to package.
* Fixed regressions.

## Version 0.4.9

* Added handy build.
* Fix grammar.
* Minor fixes.

## Version 0.4.8

* Added support for wireless connections.
* Minor fixes.

## Version 0.4.7

* Minor fixes.

## Version 0.4.6

* Minor fixes.
* Fixed live uefi installation.
* Library (alexpro100_lib) fixes.

## Version 0.4.5

* Minor fixes.
* Removed errors on start of live installer.

## Version 0.4.4

* Added disk operations to live mode.
* Replaced pulseaudio with pipewire (temporaly except debian).
* Returned some install options. Removed orphaned files.
* Minor fixes.

## Version 0.4.3

* Continued work on live mode.
* Reduced size of code,
* Added language choose.

## Version 0.4.2

* Fixed busybox dialog.
* Added image maker.

## Version 0.4.1

* Added feature to change options at the end.
* Some rework of code.
* Fixes for arch and debian install.
* Library (alexpro100_lib) fixes.

## Version 0.3.8

* Busybox support,
* Soft install rework,
* Debian mirror fix.

## Version 0.3.7

* Minor fixes.
* Support for dynamic changes in profile files.
* Initial support of soft install.
* Significant speed up of installation.

## Version 0.3.5

* Minor fixes.

## Version 0.3.4

* Added partial language support.
* Fixed profile generator.
* Alpine linux network fix.

## Version 0.3.3

* Added whiptail support.

## Version 0.3.2

* Minor fixes.
* Support for busybox use.
* Added CUSTOM_DIR flag.

## Version 0.3.1

* Minor fixes.
* Fixed password enter bug.
* Fixed debian boot issues (bootloader choose and grub2 install).

## Version 0.3.0

* Minor fixes.
* Added auto mode.
* Added unit tests.

## Version 0.2.9

* Minor fixes.
* Added scripts for mirror sync.
* Support of alpine install.

## Version 0.2.8

* Small fixes.
* Temporary disabled extended features.

## Version 0.2.7

* Bug fixes;
* Initial support of voidlinux interactive install.

## Version 0.2.6

* Support of archlinux and debian install.
* Support for any repos in debian.

## Version 0.2.5

* Returning support of debian install. WIP.
* Rewrting support of archlinux install.
* Working on offline installation.

## Version 0.2.4

* Split to two parts: profile generator and installer.
* Added debug feature to own framework.
* Fixed possible error with qemu emulation.
* Minor fixes and cleanup.

## Version 0.2.3

* Return support of debian installation.
* Begin of making offline setup support.

## Version 0.2.2

* Fix fstab bug.
* Temporaly removed support of debian installation.

## Version 0.2.1

* Partial support of foreign architectures.
* Full rewrite.
* Support only for archlinux.
* Link to new own framework.
* Add support for zst archives.
* Clean up.
* Fix grammar.
