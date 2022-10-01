linux_install (tests)
============================

This is a directory, where you can find scripts for testing linux_install work.
They test "auto mode" for different distritbutions. Profile is generated automatically.
To use them, run `./your_test.sh distr_name | tee log.txt`.

### Contents:
* qemu_test_bios.sh - Test installation of specified distribution on amd64 BIOS virtual machine. Requries QEMU.
* qemu_test_uefi.sh - Test installation of specified distribution on amd64 UEFI virtual machine. Requries QEMU and OVMF.
* to_dir_test.sh - Test installation of specified distribution to directory.
* profile_test.sh - Test specified profile installation to directory.