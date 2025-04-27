#!/usr/bin/env zsh

powerline_precmd() {
    PS1="$(powerline-go \
      -error "$?" \
      -shell zsh \
      -modules 'venv,ssh,cwd,perms,git,jobs,exit' \
    )"
}

install_powerline_precmd() {
  local s
  for s in "${precmd_functions[@]}"; do
    if [[ "${s}" = "powerline_precmd" ]]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [[ "${TERM}" != "linux" ]] && type powerline-go &>/dev/null; then
    install_powerline_precmd
fi

setopt interactive_comments

bindkey -e
bindkey '^U' backward-kill-line
