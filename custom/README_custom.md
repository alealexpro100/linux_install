linux_install (custom options)
==============================

This is a directory, where you can add your custom script and files. Script will be executed after copying custom files (if exist).
Flag `CUSTOM_DIR` is supported.

### Contents:
* rootfs - (If exists) files from this directory will be copied to root of your newly installed system.
* custom_script.sh - (If exists) script, which will be executed in rootfs after installing system.
