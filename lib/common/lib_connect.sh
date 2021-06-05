#!/bin/bash

#Use library
if [[ -z $ALEXPRO100_LIB_VERSION ]]; then
  ALEXPRO100_LIB_LOCATION="${ALEXPRO100_LIB_LOCATION:-${BASH_SOURCE[0]%/*}/alexpro100_lib.sh}"
  if [[ -f $ALEXPRO100_LIB_LOCATION ]]; then
    echo "Using $ALEXPRO100_LIB_LOCATION."
  else
   echo -e "$ALEXPRO100_LIB_LOCATION not found!"; exit 1
  fi
  # shellcheck disable=SC1090
  source "$ALEXPRO100_LIB_LOCATION"
fi
