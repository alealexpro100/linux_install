
#Add and change variables.
declare -a var_num
declare -A var_list
function add_var() {
  local type="$1" var="$2" content="$3"
  [[ -z ${var_list[$var]} ]] && var_num=("${var_num[@]}" "$var")
  var_list[$var]="add_var \"$type\" $var"
  if [[ -n $content ]]; then
    var_list[$var]="${var_list[$var]} \"$content\""
    $type $var="$content"
  else
    $type $var
  fi
}

#Exports all variables for add_var.
function var_export() {
  echo -e "#Generated on $(date -u).\n"
  for var in "${var_num[@]}"; do
    echo -e "${var_list[$var]}"
  done
}