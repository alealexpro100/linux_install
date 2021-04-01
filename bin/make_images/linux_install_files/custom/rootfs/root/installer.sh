#!/bin/bash

source ~/linux_install/bin/alexpro100_lib.sh

msg_print note "Welcome to ALEXPRO100 Linux install!"
mkdir ~/bin
declare -gx ECHO_MODE=dialog LIVE_MODE=1
msg_print warning "To run installer, type ./linux_install/profile_gen.sh and then ./linux_install/install_sys.sh"