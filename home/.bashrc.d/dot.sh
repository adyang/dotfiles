#!/bin/bash

# shellcheck source=/dev/null
source "${HOME}/.dot-env"

dot::vim() {
  "${DOT_DIR}"/configure-vim
}

dot::install() {
  "${DOT_DIR}"/install
}
