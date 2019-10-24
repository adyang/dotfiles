#!/bin/bash

# shellcheck source=/dev/null
source "${HOME}/.dot-env"

dot::install() {
  "${DOT_DIR}"/install
}

dot::vim() {
  "${DOT_DIR}"/configure-vim
}

dot::firefox() {
  "${DOT_DIR}"/configure-firefox
}

dot::vscode() {
  "${DOT_DIR}"/configure-vscode
}

dot::macos() {
  "${DOT_DIR}"/configure-macos
}
