#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'mock_helper'

setup() {
  tmp_dot_home="$(mktemp -d)"
  DOT_HOME="${tmp_dot_home}"
  tmp_script_dir="$(mktemp -d)"
  SCRIPT_DIR="${tmp_script_dir}"
  source "${BATS_TEST_DIRNAME}/../install" 
}

teardown() {
  rm -rf "${tmp_dot_home}"
  rm -rf "${tmp_script_dir}"
}

@test "[install] sudo_keep_alive: password validation failure" {
  sudo_until_process_ends() {
    echo '[FAILURE] should exit immediately on sudo validation failure'
  }

  run sudo_keep_alive <<< $'wrong\nwrong\nwrong\n'

  assert_failure 1
  refute_output --partial '[FAILURE]'
}

@test "[install] brew_kext_packages: brew update fails" {
  mock_failure 'brew' 'update'

  run brew_kext_packages <<<$'\n'

  assert_failure 1
  refute_line --partial 'brew bundle'
}

@test "[install] brew_kext_packages: first brew bundle succeeds" {
  mock_echo 'brew'

  run brew_kext_packages <<<$'\n'

  assert_success
  assert_equal "${#lines[@]}" 2
  assert_line --index 1 --regexp '^brew bundle --verbose --file=.*Brewfile-kext$'
}

@test "[install] brew_kext_packages: first brew bundle fails" {
  attempt_count=0
  brew() {
    [[ "$1" == 'bundle' ]] || return 0;
    attempt_count=$(( attempt_count + 1 ))
    if (( attempt_count == 1 )); then
      return 1
    else
      echo "brew $*"
    fi
  }

  run brew_kext_packages <<<$'\n'

  assert_success
  assert_line --index 0 --partial 'Please allow kext installation'
  assert_line --index 1 --regexp '^brew bundle --verbose --file=.*Brewfile-kext$'
}

@test "[install] brew_kext_packages: first brew bundle fails and read fails" {
  attempt_count=0
  brew() {
    [[ "$1" == 'bundle' ]] || return 0;
    attempt_count=$(( attempt_count + 1 ))
    if (( attempt_count == 1 )); then
      return 1
    else
      echo "brew $*"
    fi
  }
  mock_failure 'read'

  run brew_kext_packages

  assert_failure 1
  assert_line --index 0 --partial 'Please allow kext installation'
  refute_line --index 1 'brew bundle --verbose --file=Brewfile-kext'
}

@test "[install] brew_kext_packages: first brew bundle fails and second brew bundle fails" {
  mock_failure 'brew' 'bundle'
  brew_kext_packages_with_exit_test() {
    brew_kext_packages <<<$'\n'
    echo '[FAILURE] failed to exit'
  }

  run brew_kext_packages_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

@test "[install] brew_packages: brew update fails" {
  mock_failure 'brew' 'update'

  run brew_packages

  assert_failure 1
  refute_line --partial 'brew bundle'
}

@test "[install] brew_packages: brew bundle fails" {
  mock_failure 'brew' 'bundle'
  brew_packages_with_exit_test() {
    brew_packages
    echo '[FAILURE] failed to exit'
  }

  run brew_packages_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

@test "[install] install_powerline: powerline-go already installed" {
  mock_echo 'curl'
  mkdir -p "${DOT_HOME}/.powerline-go"
  touch "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0"
  
  run install_powerline

  assert_success
  refute_line --partial 'curl'
}

@test "[install] install_powerline: powerline-go not installed" {
  curl() {
    mkdir -p "${DOT_HOME}/.powerline-go"
    touch "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0"
  }

  run install_powerline

  assert_success
  assert [ "${DOT_HOME}/.local/bin/powerline-go" -ef "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
}

@test "[install] install_powerline: powerline-go not installed but download fails" {
  curl() {
    return 22
  }
  
  run install_powerline

  assert_failure 22
  refute [ -x "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
  refute [ -d "${DOT_HOME}/.local/bin" ]
  refute [ "${DOT_HOME}/.local/bin/powerline-go" -ef "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
}

@test "[install] symlink_dotfiles: regular file with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/present-file"
  echo 'present-file' > "${tmp_dot_home}/present-file"
  
  run symlink_dotfiles

  assert_success
  assert [ "$(cat "${tmp_dot_home}/present-file.bak")" == 'present-file' ]
  assert [ "${tmp_dot_home}/present-file" -ef "${tmp_script_dir}/home/present-file" ]
}

@test "[install] symlink_dotfiles: directory with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/same-name"
  mkdir "${tmp_dot_home}/same-name"
  
  run symlink_dotfiles

  assert_success
  assert [ -d "${tmp_dot_home}/same-name" ]
  refute [ -e "${tmp_dot_home}/same-name.bak" ]
  refute [ "${tmp_dot_home}/same-name" -ef "${tmp_script_dir}/home/same_name" ]
}

@test "[install] symlink_dotfiles: symlink with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/same-name"
  touch "${tmp_dot_home}/old-src"
  ln -sv "${tmp_dot_home}/old-src" "${tmp_dot_home}/same-name"
  
  run symlink_dotfiles

  assert_success
  assert [ "${tmp_dot_home}/same-name" -ef "${tmp_dot_home}/old-src" ]
  refute [ -e "${tmp_dot_home}/same-name.bak" ]
}

@test "[install] symlink_dotfiles: hidden and non-hidden dotfiles" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/"{.hidden,non-hidden}
  mkdir "${tmp_script_dir}/home/"{.hidden-dir,non-hidden-dir}
  
  run symlink_dotfiles

  assert_success
  for file in .hidden non-hidden .hidden-dir non-hidden-dir; do
    assert [ "${tmp_dot_home}/${file}" -ef "${tmp_script_dir}/home/${file}" ]
  done
}

@test "[install] symlink_dotfiles: nested home files" {
  mkdir -p "${tmp_script_dir}/home-nested/nest1/nest2"
  touch "${tmp_script_dir}/home-nested/nest1/nest2/nested-file"
  
  run symlink_dotfiles

  assert_success
  assert [ "${tmp_dot_home}/nest1/nest2/nested-file" -ef "${tmp_script_dir}/home-nested/nest1/nest2/nested-file" ]
  refute [ -L "${tmp_dot_home}/nest1" ]
  refute [ -L "${tmp_dot_home}/nest1/nest2" ]
}

@test "[install] symlink_dotfiles: backup of regular file fails" {
  backup_if_regular_file() {
    return 1
  }
  mock_echo 'symlink_if_absent'
  
  run symlink_dotfiles

  assert_failure 1
  refute_line --partial 'symlink_if_absent'
}

@test "[install] symlink_dotfiles: symlink fails" {
  symlink_if_absent() {
    return 1
  }
  symlink_dotfiles_with_exit_test() {
    symlink_dotfiles
    echo '[FAILURE] failed to exit'
  }
  
  run symlink_dotfiles_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

@test "[install] configure_vscode: configs absent" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  
  run configure_vscode

  assert_success
  for file in snippets keybindings.json settings.json; do
    assert [ "${tmp_dot_home}/Library/Application Support/Code/User/${file}" -ef "${tmp_script_dir}/vscode/${file}" ]
  done
}

@test "[install] configure_vscode: configs present" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mkdir -p "${tmp_dot_home}/Library/Application Support/Code/User"
  printf 'present-file' > "${tmp_dot_home}/Library/Application Support/Code/User/keybindings.json"
  printf 'present-file' > "${tmp_dot_home}/Library/Application Support/Code/User/settings.json"
  
  run configure_vscode

  assert_success
  for file in keybindings.json settings.json; do
    assert [ "$(cat "${tmp_dot_home}/Library/Application Support/Code/User/${file}.bak")" == 'present-file' ]
    assert [ "${tmp_dot_home}/Library/Application Support/Code/User/${file}" -ef "${tmp_script_dir}/vscode/${file}" ]
  done
}

@test "[install] configure_vscode: backup of regular file fails" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mock_failure 'backup_if_regular_file'
  mock_echo 'symlink_if_absent'
  
  run configure_vscode

  assert_failure 1
  refute_line --partial 'symlink_if_absent'
}

@test "[install] configure_vscode: symlink fails" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mock_failure 'symlink_if_absent'
  configure_vscode_with_exit_test() {
    configure_vscode
    echo '[FAILURE] failed to exit'
  }
  
  run configure_vscode_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

@test "[install] configure_asdf_plugins: source asdf fails" {
  source() {
    return 1
  }
  mock_echo 'configure_plugin'
  echo 'plugin 1.0.0' > "${tmp_dot_home}/.tool-versions"

  run configure_asdf_plugins

  assert_failure 1
  refute_line --partial 'configure_plugin'
}

@test "[install] configure_asdf_plugins: upadd_plugin fails" {
  upadd_plugin() {
    return 1
  }
  mock_echo 'source'
  mock_echo 'install_plugin_versions'
  echo 'plugin 1.0.0' > "${tmp_dot_home}/.tool-versions"

  run configure_asdf_plugins

  assert_failure 1
  refute_line --partial 'install_plugin_versions'
}

@test "[install] configure_asdf_plugins: asdf install <plugin> <version> fails" {
  mock_failure 'asdf' 'install'
  mock_echo 'source'
  mock_echo 'upadd_plugin'
  echo 'plugin 1.0.0' > "${tmp_dot_home}/.tool-versions"

  run configure_asdf_plugins

  assert_failure 1
  refute_line --partial 'asdf global'
}

@test "[install] install_pip_packages: upgrade pip fails" {
  mock_failure 'python' '-m pip install --upgrade pip' 

  run install_pip_packages

  assert_failure 1
  refute_line 'python -m pip install --upgrade --user pipx'
}

@test "[install] install_pip_packages: install pipx fails" {
  mock_failure 'python' '-m pip install --upgrade --user pipx'

  run install_pip_packages

  assert_failure 1
  refute_line --partial 'pipx'
}

@test "[install] install_pip_packages: pipx install ansible fails" {
  mock_failure 'python' '-m pipx install ansible'

  run install_pip_packages

  assert_failure 1
  refute_line --partial 'pipx install'
}

@test "[install] install_pip_packages: pipx install yolk3k fails" {
  mock_failure 'python' '-m pipx install yolk3k'

  install_pip_packages_with_exit_test() {
    install_pip_packages
    echo '[FAILURE] failed to exit'
  }

  run install_pip_packages_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

