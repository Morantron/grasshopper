BEGIN {
  config_namespace = ""
  config_prefix = "grasshopper_"
}

{
  line = $0

  if (line ~ "\\[ssh\\]") {
    config_namespace = "ssh"
    next
  }

  if (line ~ "\\[paths\\]") {
    config_namespace = "paths"
    next
  }

  if (line ~ "=>") {
    host_path = line
    guest_path = line
    sub(" ?=> ?.*", "", host_path)
    sub(".* ?=> ?", "", guest_path)
    path_map[host_path] = guest_path
    next
  }

  if (line ~ "[a-z]+=.*") {
    match(line, "[a-z]+=")
    var_name = substr(line, RSTART, RLENGTH - 1)
    var_value = substr(line, RSTART + RLENGTH)

    var_key = config_namespace "_" var_name
    variables[var_key] = var_value
    next
  }
}

END {
  path_map_var_name = config_prefix "path_map"
  print "declare -A " path_map_var_name
  for (host_path in path_map) {
    guest_path = path_map[host_path]
    print path_map_var_name "[" host_path "]='" guest_path "'"
  }

  for (variable in variables) {
    value = variables[variable]
    print config_prefix variable "='" value "'"
  }
}
