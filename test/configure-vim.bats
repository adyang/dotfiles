#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'mock_helper'

setup() {
  tmp_dot_home="$(mktemp -d)"
  DOT_HOME="${tmp_dot_home}"
  source "${BATS_TEST_DIRNAME}/../configure-vim" 
}

teardown() {
  rm -rf "${tmp_dot_home}"
}

@test "[configure-vim] install_vim_plugins: plugin is not installed" {
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git clone https://github.com/dense-analysis/plugin.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin"
}

@test "[configure-vim] install_vim_plugins: plugin is not installed but git clone fails" {
  git() {
    return 1
  }
  mock_echo 'vim'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "[configure-vim] install_vim_plugins: plugin is already installed" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin pull origin master"
}

@test "[configure-vim] install_vim_plugins: plugin is installed but git pull fails" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin"
  git() {
    return 1
  }
  mock_echo 'vim'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin.git'

  assert_failure 1
  refute_line --partial 'vim'
}

@test "[configure-vim] install_vim_plugins: multiple plugins" {
  mkdir -p "${tmp_dot_home}/.vim/pack/plugins/start/plugin1"
  mock_echo 'git'

  run install_vim_plugins 'https://github.com/dense-analysis/plugin1.git' 'https://github.com/dense-analysis/plugin2.git'

  assert_success
  assert_line "git -C ${tmp_dot_home}/.vim/pack/plugins/start/plugin1 pull origin master"
  assert_line "git clone https://github.com/dense-analysis/plugin2.git ${tmp_dot_home}/.vim/pack/plugins/start/plugin2"
}

