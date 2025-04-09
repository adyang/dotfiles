#!/bin/bash

backup_if_regular_file() {
  local filepath="$1"
  if [[ -f "${filepath}" && ! -L "${filepath}" ]]; then
    mv -v "${filepath}" "${filepath}.bak"
  fi
}

symlink_if_absent() {
  local src="$1"
  local target="$2"
  if [[ ! -e "${target}" && ! -L "${target}" ]]; then
    ln -sv "${src}" "${target}"
  fi
}
