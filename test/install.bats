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
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run brew_packages

  assert_success
  assert_line --index 0 '/usr/bin/ruby -e brew-script'
}


@test "brew_packages: homebrew is not installed but download fails" {
  mock_is_brew_installed 1
  curl() {
    return 22
  }
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run brew_packages

  assert_failure 22
  refute_output --partial '/usr/bin/ruby'
  refute_output --partial 'brew'
}

@test "brew_packages: homebrew is installed" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run brew_packages

  assert_success
  refute_output --partial 'curl'
  refute_output --partial '/usr/bin/ruby'
}

@test "brew_packages: brew commands are all successful" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo '/usr/bin/ruby'
  mock_echo 'brew'

  run brew_packages

  assert_success
  assert_line --index 0 'brew analytics off'
  assert_line --index 1 'brew analytics'
  assert_line --index 2 'brew update'
  assert_line --index 3 'brew bundle --verbose'
}

@test "brew_packages: brew update fails" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo '/usr/bin/ruby'
  mock_failure 'brew' 'update'

  run brew_packages

  assert_failure 1
  refute_line --partial 'brew bundle'
}

@test "brew_packages: brew bundle fails" {
  mock_is_brew_installed 0
  mock_echo 'curl'
  mock_echo '/usr/bin/ruby'
  mock_failure 'brew' 'bundle'
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

@test "install_powerline: powerline-go already installed" {
  mock_echo 'curl'
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
  mock_echo 'cd'
  
  run find_script_dir

  assert_failure 1
  refute_line --partial 'cd'
}

@test "find_script_dir: cd fails" {
  cd() {
    return 1;
  }
  mock_echo 'pwd'
  
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
  mock_echo 'symlink_if_absent'
  
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
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git clone https://github.com/dense-analysis/plugin.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin"
}

@test "install_vim_plugins: plugin is not installed but git clone fails" {
  git() {
    return 1
  }
  mock_echo 'vim'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "install_vim_plugins: plugin is already installed" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin pull origin master"
}

@test "install_vim_plugins: plugin is installed but git pull fails" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  git() {
    return 1
  }
  mock_echo 'vim'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "install_vim_plugins: multiple plugins" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin1"
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin1.git' 'https://github.com/dense-analysis/plugin2.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin1 pull origin master"
  assert_line "git clone https://github.com/dense-analysis/plugin2.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin2"
}

@test "configure_asdf_plugins: source asdf fails" {
  source() {
    return 1
  }
  mock_echo 'configure_plugin'
  echo 'plugin 1.0.0' > "${tmp_dot_home}/.tool-versions"

  run configure_asdf_plugins

  assert_failure 1
  refute_line --partial 'configure_plugin'
}

@test "configure_asdf_plugins: upadd_plugin fails" {
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

@test "configure_asdf_plugins: asdf install <plugin> <version> fails" {
  mock_failure 'asdf' 'install'
  mock_echo 'source'
  mock_echo 'upadd_plugin'
  echo 'plugin 1.0.0' > "${tmp_dot_home}/.tool-versions"

  run configure_asdf_plugins

  assert_failure 1
  refute_line --partial 'asdf global'
}

@test "install_pip_packages: upgrade pip fails" {
  mock_failure 'python' '-m pip install --upgrade pip' 
  mock_echo 'pipx'

  run install_pip_packages

  assert_failure 1
  refute_line 'python -m pip install --upgrade --user pipx'
}

@test "install_pip_packages: install pipx fails" {
  mock_failure 'python' '-m pip install --upgrade --user pipx'
  mock_echo 'pipx'

  run install_pip_packages

  assert_failure 1
  refute_line --partial 'pipx'
}

@test "install_pip_packages: pipx install ansible fails" {
  mock_failure 'pipx' 'install ansible'
  mock_echo 'python'

  run install_pip_packages

  assert_failure 1
  refute_line --partial 'pipx install'
}

@test "install_pip_packages: pipx install yolk3k fails" {
  mock_failure 'pipx' 'install yolk3k'
  mock_echo 'python'
  install_pip_packages_with_exit_test() {
    install_pip_packages
    echo '[FAILURE] failed to exit'
  }

  run install_pip_packages_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

mock_echo() {
  . /dev/stdin <<EOF
    $1() {
      echo "$1 \$*"
    }
EOF
}

mock_failure() {
  local cmd="$1"
  local failure_args="${*:2}"
  . /dev/stdin <<EOF
    ${cmd}() {
      if [[ "\$*" == '${failure_args}'* ]]; then
        return 1
      else
        echo "${cmd} \$*"
      fi
    }
EOF
}

