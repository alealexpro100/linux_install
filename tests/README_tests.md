linux_install (test scripts)
==============================

This is a directory, where you can find scripts for testing linux_install work.
Questions are tested by user manually, but installing of "auto mode" can be tested by this.
To use them, run `your_test.sh distr_name | tee log.txt`.

### Contents:
* qemu_test.sh - Test installation on virtual machine. Requries manual actions in VM.
* to_dir_test.sh - Test installation of all supported distros to directory.
* to_img_test.sh - Test installation of all supported distros to virtual disk.
