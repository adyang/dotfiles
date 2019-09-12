#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

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

@test "symlink_dotfiles: regular file with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/present-file"
  echo 'present-file' > "${tmp_dot_home}/present-file"
  
  run symlink_dotfiles

  assert_success
  assert [ "$(cat "${tmp_dot_home}/present-file.bak")" == 'present-file' ]
  assert [ "${tmp_dot_home}/present-file" -ef "${tmp_script_dir}/home/present-file" ]
}

@test "symlink_dotfiles: directory with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/same-name"
  mkdir "${tmp_dot_home}/same-name"
  
  run symlink_dotfiles

  assert_success
  assert [ -d "${tmp_dot_home}/same-name" ]
  refute [ -e "${tmp_dot_home}/same-name.bak" ]
  refute [ "${tmp_dot_home}/same-name" -ef "${tmp_script_dir}/home/same_name" ]
}

@test "symlink_dotfiles: symlink with same name as home file present" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/same-name"
  touch "${tmp_dot_home}/old-src"
  ln -sv "${tmp_dot_home}/old-src" "${tmp_dot_home}/same-name"
  
  run symlink_dotfiles

  assert_success
  assert [ "${tmp_dot_home}/same-name" -ef "${tmp_dot_home}/old-src" ]
  refute [ -e "${tmp_dot_home}/same-name.bak" ]
}

@test "symlink_dotfiles: hidden and non-hidden dotfiles" {
  mkdir "${tmp_script_dir}/home"
  touch "${tmp_script_dir}/home/"{.hidden,non-hidden}
  mkdir "${tmp_script_dir}/home/"{.hidden-dir,non-hidden-dir}
  
  run symlink_dotfiles

  assert_success
  for file in .hidden non-hidden .hidden-dir non-hidden-dir; do
    assert [ "${tmp_dot_home}/${file}" -ef "${tmp_script_dir}/home/${file}" ]
  done
}

@test "symlink_dotfiles: nested home files" {
  mkdir -p "${tmp_script_dir}/home-nested/nest1/nest2"
  touch "${tmp_script_dir}/home-nested/nest1/nest2/nested-file"
  
  run symlink_dotfiles

  assert_success
  assert [ "${tmp_dot_home}/nest1/nest2/nested-file" -ef "${tmp_script_dir}/home-nested/nest1/nest2/nested-file" ]
}

@test "symlink_dotfiles: backup of regular file fails" {
  backup_if_regular_file() {
    return 1
  }
  symlink_if_absent() {
    echo "symlink_if_absent $@"
  }
  
  run symlink_dotfiles

  assert_failure 1
  refute_line --partial 'symlink_if_absent'
}

@test "symlink_dotfiles: symlink fails" {
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

@test "install_vim_plugins: plugin is not installed" {
  mock_git_echo

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git clone https://github.com/dense-analysis/plugin.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin"
}

@test "install_vim_plugins: plugin is not installed but git clone fails" {
  git() {
    return 1
  }
  mock_vim_echo

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "install_vim_plugins: plugin is already installed" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  mock_git_echo

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin pull origin master"
}

@test "install_vim_plugins: plugin is installed but git pull fails" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  git() {
    return 1
  }
  mock_vim_echo

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "install_vim_plugins: multiple plugins" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin1"
  mock_git_echo

  run install_vim_plugins 'https://github.com/dense-analysis/plugin1.git' 'https://github.com/dense-analysis/plugin2.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin1 pull origin master"
  assert_line "git clone https://github.com/dense-analysis/plugin2.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin2"
}

mock_git_echo() {
  git() {
    echo "git $@"
  }
}

mock_vim_echo() {
  vim() {
    echo "vim $@"
  }
}

