#!/bin/bash

#Add and change variables.
declare -a var_num
declare -A var_list
function add_var() {
  local type="$1" var="$2" content="$3"
  if [[ $NO_VAR != "1" ]]; then
    [[ -z ${var_list[$var]} ]] && var_num=("${var_num[@]}" "$var")
    var_list[$var]="\"$type\" \"$var\""
    [[ -n $content ]] && var_list[$var]="${var_list[$var]} \"$content\""
  fi
  if [[ -n $content ]]; then
    $type "$var"="$content"
  else
    $type "$var"
  fi
}

#Exports all variables for add_var.
function var_export() {
  for var in "${var_num[@]}"; do
    echo -e "$1${var_list[$var]}"
  done
}