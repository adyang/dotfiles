if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for completion in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "${completion}" ]] && source "${completion}"
    done
  fi
fi

eval "$(register-python-argcomplete pipx)"

