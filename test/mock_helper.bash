#!/bin/bash

mock_echo() {
  . /dev/stdin <<EOF
    $1() {
      echo "$1 \$*"
    }
EOF
}

mock_failure() {
  local cmd="$1"
  local failure_args="${*:2}"
  . /dev/stdin <<EOF
    ${cmd}() {
      if [[ "\$*" == '${failure_args}'* ]]; then
        return 1
      else
        echo "${cmd} \$*"
      fi
    }
EOF
}

