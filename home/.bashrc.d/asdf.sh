#!/bin/bash

source /usr/local/opt/asdf/asdf.sh

asdf_java_home() {
  local asdf_java_path
  if asdf current java >/dev/null 2>&1; then
    asdf_java_path="$(asdf which java)" || return "$?"
    export JAVA_HOME="${asdf_java_path%/*/*}"
  fi
}

asdf_java_home
