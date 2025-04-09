#!/bin/bash

await() {
  local commands=("$@")
  local timeoutSecs=15
  local current expiry

  current="$(date +%s)"
  expiry="$(( current + timeoutSecs ))"
  until "${commands[@]}"; do
    current="$(date +%s)"
    if (( current > expiry )); then
      echo "Timeout retrying: '${commands[@]}'"
      return 124
    fi
  done
}
