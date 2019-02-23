#!/bin/bash

echo 'Running second stage...'
/debootstrap/debootstrap --second-stage

echo 'Starting next script.'
bash /root/pi_s1.sh

rm -rf /root/pi_s0.sh
