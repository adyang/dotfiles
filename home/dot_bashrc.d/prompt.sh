#!/bin/bash

_update_ps1() {
  PS1="$("$(brew --prefix powerline-go)/bin/powerline-go" \
      -error "$?" \
      -modules 'venv,ssh,cwd,perms,git,jobs,exit' \
    )"
}

if [[ "${TERM}" != "linux" ]] && [[ -f "$(brew --prefix powerline-go)/bin/powerline-go" ]]; then
    PROMPT_COMMAND="_update_ps1; ${PROMPT_COMMAND:-:}"
fi
