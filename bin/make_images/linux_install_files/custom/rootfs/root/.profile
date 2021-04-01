#!/bin/bash

if [[ -f ~/installer.sh ]]; then
    bash ~/installer.sh
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
