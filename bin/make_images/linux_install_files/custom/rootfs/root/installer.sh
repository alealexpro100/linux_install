#!/bin/bash

#Import some libraries.
source ~/linux_install/bin/alexpro100_lib.sh
source ~/linux_install/lib/common/lib_var_op.sh
source ~/linux_install/lib/common/lib_ui.sh

msg_print note "Welcome to ALEXPRO100 Linux install!"
read_param "install - run integrated installer\nconsole - switch to console mode.\n" "Choose work mode (install/console)" "install" WORK_MODE text_check install,console
if [[ $WORK_MODE == "install" ]]; then
    read_param "dialog - Use dialog while installation.\ncli - use console while installation.\n" "Choose echo mode (dialog/cli)" "dialog" ECHO_MODE text_check dialog,cli
    LIVE_MODE=1 ./linux_install/profile_gen.sh
    ./linux_install/install_sys.sh /tmp/last_gen.sh
fi

msg_print warning "To run installer, type ./linux_install/profile_gen.sh and then ./linux_install/install_sys.sh"