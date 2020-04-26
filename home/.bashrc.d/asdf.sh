#!/bin/bash

source /usr/local/opt/asdf/asdf.sh

asdf_java_home() {
  local java_path
  java_path="$(asdf which java)"
  if [[ -n "${java_path}" ]]; then
    export JAVA_HOME="${java_path%/*/*}"
  fi
}

PROMPT_COMMAND="${PROMPT_COMMAND:-:}; asdf_java_home"
