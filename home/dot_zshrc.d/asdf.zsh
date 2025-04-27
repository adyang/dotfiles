#!/usr/bin/env zsh

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

asdf_java_home() {
  local java_path
  java_path="$(asdf where java)"
  if [[ -n "${java_path}" ]]; then
    export JAVA_HOME="${java_path}"
  fi
}

precmd_functions+=(asdf_java_home)
