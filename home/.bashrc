PATH="${PATH}:${HOME}/.local/bin"

export LC_ALL='en_US.UTF-8'

for script in "${HOME}"/.bashrc.d/*.sh; do
  if [[ -r "${script}" ]]; then
    source "${script}"
  fi
done

