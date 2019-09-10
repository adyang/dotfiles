#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "sudo_keep_alive: password validation failure" {
  sudo_until_process_ends() {
    echo '[FAILURE] should exit immediately on sudo validation failure'
  }

  run sudo_keep_alive <<< $'wrong\nwrong\nwrong\n'

  assert_failure 1
  refute_output --partial '[FAILURE]'
}

@test "brew_packages: homebrew is not installed" {
  mock_is_brew_installed 1
  curl() {
    echo 'brew-script'
  }
  mock_ruby_echo
  mock_brew_echo

  run brew_packages

  assert_success
  assert_line --index 0 'ruby -e brew-script'
}


@test "brew_packages: homebrew is not installed but download fails" {
  mock_is_brew_installed 1
  curl() {
    return 22
  }
  mock_ruby_echo
  mock_brew_echo

  run brew_packages

  assert_failure 22
  refute_output --partial 'ruby'
  refute_output --partial 'brew'
}

@test "brew_packages: homebrew is installed" {
  mock_is_brew_installed 0
  mock_curl_echo
  mock_ruby_echo
  mock_brew_echo

  run brew_packages

  assert_success
  refute_output --partial 'curl'
  refute_output --partial 'ruby'
}

@test "brew_packages: brew commands are all successful" {
  mock_is_brew_installed 0
  mock_curl_echo
  mock_ruby_echo
  mock_brew_echo

  run brew_packages

  assert_success
  assert_line --index 0 'brew analytics off'
  assert_line --index 1 'brew analytics'
  assert_line --index 2 'brew update'
  assert_line --index 3 'brew bundle --verbose'
}

@test "brew_packages: brew update fails" {
  mock_is_brew_installed 0
  mock_curl_echo
  mock_ruby_echo
  mock_brew_failure 'update'

  run brew_packages

  assert_failure 1
  refute_line --partial 'brew bundle'
}

@test "brew_packages: brew bundle fails" {
  mock_is_brew_installed 0
  mock_curl_echo
  mock_ruby_echo
  mock_brew_failure 'bundle'
  brew_packages_with_exit_test() {
    brew_packages
    echo '[FAILURE] failed to exit'
  }

  run brew_packages_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
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

mock_curl_echo() {
  curl() {
    echo "curl $@"
  }
}

mock_ruby_echo() {
  /usr/bin/ruby() {
    echo "ruby $@"
  }
}

mock_brew_echo() {
  brew() {
    echo "brew $@"
  }
}

mock_brew_failure() {
  failure_cmd="$1"
  brew() {
    if [[ "$1" == "${failure_cmd}" ]]; then
      return 1
    else
      echo "brew $@"
    fi
  }
}

setup() {
  tmpdir="$(mktemp -d)"
  DOT_HOME="${tmpdir}"
  source "${BATS_TEST_DIRNAME}/../install" 
}

teardown() {
  rm -rf "${tmpdir}"
}

@test "install_powerline: powerline-go already installed" {
  mock_curl_echo
  mkdir -p "${DOT_HOME}/.powerline-go"
  touch "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0"
  
  run install_powerline

  assert_success
  refute_line --partial 'curl'
}

@test "install_powerline: powerline-go not installed" {
  curl() {
    mkdir -p "${DOT_HOME}/.powerline-go"
    touch "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0"
  }

  run install_powerline

  assert_success
  assert [ "${DOT_HOME}/.local/bin/powerline-go" -ef "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
}

@test "install_powerline: powerline-go not installed but download fails" {
  curl() {
    return 22
  }
  
  run install_powerline

  assert_failure 22
  refute [ -x "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
  refute [ -d "${DOT_HOME}/.local/bin" ]
  refute [ "${DOT_HOME}/.local/bin/powerline-go" -ef "${DOT_HOME}/.powerline-go/powerline-go-darwin-amd64-v1.13.0" ]
}

@test "find_script_dir: dirname fails" {
  dirname() {
    return 1
  }
  cd() {
    echo "cd $@"
  }
  
  run find_script_dir

  assert_failure 1
  refute_line --partial 'cd'
}

@test "find_script_dir: cd fails" {
  cd() {
    return 1;
  }
  pwd() {
    echo "pwd $@"
  }
  
  run find_script_dir

  assert_failure 1
  refute_line --partial 'pwd'
}

@test "find_script_dir: success" {
  run find_script_dir

  assert_success
  assert_output "${BATS_TEST_DIRNAME%/*}"
}

@test "find_script_dir: cd writes noise to stdout and stderr" {
  cd() {
    echo 'stdout noise'
    echo 'stderr noise' >&2
    unset -f cd
    cd "$1"
  }
  
  run find_script_dir

  assert_success
  assert_output "${BATS_TEST_DIRNAME%/*}"
}

