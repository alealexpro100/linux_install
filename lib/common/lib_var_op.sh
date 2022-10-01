#!/bin/bash

# Actual variable set.
declare -a var_num
declare -A var_list

# Add variable to array (variable set)
# Options:
# * NO_VAR=1 - Do not add variable to variable set.
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

# Output commands to write back options.
function var_export() {
  for var in "${var_num[@]}"; do
    echo -e "$1${var_list[$var]}"
  done
}