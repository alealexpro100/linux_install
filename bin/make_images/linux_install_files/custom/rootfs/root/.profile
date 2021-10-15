#!/bin/bash

if [[ -f ~/installer.sh ]]; then
    bash ~/installer.sh
fi

#shellcheck disable=SC1090
[[ -f ~/.bashrc ]] && . ~/.bashrc
