#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'mock_helper'

setup() {
  tmp_home_dir="$(mktemp -d)"
  tmp_curr_dir="$(mktemp -d)"
  source "${BATS_TEST_DIRNAME}/../bootstrap"
}

teardown() {
  rm -rf "${tmp_home_dir}"
  rm -rf "${tmp_curr_dir}"
}

@test "[bootstrap] install_brew: homebrew is not installed" {
  mock_is_brew_installed 1
  curl() {
    echo 'brew-script'
  }
  mock_echo 'sudo'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run install_brew

  assert_success
  assert_line --index 0 'sudo mkdir -p /usr/local/lib/pkgconfig'
  assert_line --index 1 '/usr/bin/ruby -e brew-script'
}


@test "[bootstrap] install_brew: homebrew is not installed but download fails" {
  mock_is_brew_installed 1
  curl() {
    return 22
  }
  mock_echo 'sudo'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run install_brew

  assert_failure 22
  refute_output --partial '/usr/bin/ruby'
  refute_output --partial 'brew'
}

@test "[bootstrap] install_brew: homebrew is not installed but installation fails" {
  mock_is_brew_installed 1
  mock_echo 'curl'
  mock_echo 'sudo'
  mock_failure '/usr/bin/ruby'
  mock_echo 'brew'

  run install_brew

  assert_failure 1
  refute_output --partial 'brew'
}

@test "[bootstrap] install_brew: homebrew is installed" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo 'sudo'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run install_brew

  assert_success
  refute_output --partial 'curl'
  refute_output --partial '/usr/bin/ruby'
}

@test "[bootstrap] install_brew: brew commands are all successful" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo 'sudo'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run install_brew

  assert_success
  assert_line --index 0 'brew analytics off'
  assert_line --index 1 'brew analytics'
}

@test "[bootstrap] clone_dotfiles: dotfiles directory is already present" {
  mkdir "${tmp_curr_dir}/dotfiles"
  mock_echo 'git'

  run clone_dotfiles "${tmp_curr_dir}"

  assert_success
  refute_output --partial 'git clone'
}

@test "[bootstrap] clone_dotfiles: dotfiles directory is absent" {
  mock_echo 'git'

  run clone_dotfiles "${tmp_curr_dir}"

  assert_success
  assert_output --partial 'git clone'
}

@test "[bootstrap] clone_dotfiles: dotfiles directory is absent but git clone fails" {
  mock_failure 'git' 'clone'
  clone_dotfiles_with_exit_test() {
    clone_dotfiles "$@"
    echo '[FAILURE] failed to exit'
  }

  run clone_dotfiles_with_exit_test "${tmp_curr_dir}"

  assert_failure 1
  refute_output '[FAILURE] failed to exit'
}

@test "[bootstrap] setup_dot_env" {
  run setup_dot_env "${tmp_curr_dir}" "${tmp_home_dir}"

  assert_success
  assert [ -f "${tmp_home_dir}/.dot-env" ]
  assert_equal "$(cat "${tmp_home_dir}/.dot-env")" "export DOT_DIR='${tmp_curr_dir}'"
}

mock_is_brew_installed() {
  is_installed="$1"
  type() {
    if [[ "$1" == 'brew' ]]; then
      return "${is_installed}"
    else
      exit 2
    fi
  }
}

