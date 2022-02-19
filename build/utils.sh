#!/bin/bash

## 20220217 Put reused functions in a single script

## Prior to read the config file, we will check whether it is malformed
checkConfigFile () {
  ## Commented lines, empty lines und lines of the from choose_ANYNAME='any.:Value' are valid
  CONFIG_SYNTAX="^\s*#|^\s*$|^[a-zA-Z_]+='[^']*'$|^[a-zA-Z_]+=([^']*)$"

  ## Check if the file contains something we don't want
  if egrep -q -v "${CONFIG_SYNTAX}" "$CONFIG_PATH"; then
    echo "Error parsing config file ${CONFIG_PATH}." >&2
    echo "The following lines in the configfile do not fit the syntax:" >&2
    egrep -vn "${CONFIG_SYNTAX}" "$CONFIG_PATH"
    exit 5
  fi
  return 0
}

## Array functions
elementIn () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

elementInWhere () {
  index=0
  local e match="$1"
  shift
  for e
  do :
    [[ "$e" == "$match" ]] && { echo $index; return 0;}
    let index++
  done
  return -1
}
