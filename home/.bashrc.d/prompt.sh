function _update_ps1() {
    PS1="$("${HOME}/.local/bin/powerline-go" \
      -error "$?" \
      -modules 'venv,ssh,cwd,perms,git,jobs,exit' \
    )"
}

if [[ "${TERM}" != "linux" ]] && [[ -f "${HOME}/.local/bin/powerline-go" ]]; then
    PROMPT_COMMAND="_update_ps1; ${PROMPT_COMMAND}"
fi

