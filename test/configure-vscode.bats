#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'mock_helper'

setup() {
  tmp_dot_home="$(mktemp -d)"
  tmp_script_dir="$(mktemp -d)"
  source "${BATS_TEST_DIRNAME}/../configure-vscode"
}

teardown() {
  rm -rf "${tmp_dot_home}"
  rm -rf "${tmp_script_dir}"
}

@test "[configure-vscode] symlink_vscode_configs: configs absent" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json

  run symlink_vscode_configs "${tmp_script_dir}/vscode" "${tmp_dot_home}/Library/Application Support/Code/User"

  assert_success
  for file in snippets keybindings.json settings.json; do
    assert [ "${tmp_dot_home}/Library/Application Support/Code/User/${file}" -ef "${tmp_script_dir}/vscode/${file}" ]
  done
}

@test "[configure-vscode] symlink_vscode_configs: configs present" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mkdir -p "${tmp_dot_home}/Library/Application Support/Code/User"
  printf 'present-file' > "${tmp_dot_home}/Library/Application Support/Code/User/keybindings.json"
  printf 'present-file' > "${tmp_dot_home}/Library/Application Support/Code/User/settings.json"

  run symlink_vscode_configs "${tmp_script_dir}/vscode" "${tmp_dot_home}/Library/Application Support/Code/User"

  assert_success
  for file in keybindings.json settings.json; do
    assert [ "$(cat "${tmp_dot_home}/Library/Application Support/Code/User/${file}.bak")" == 'present-file' ]
    assert [ "${tmp_dot_home}/Library/Application Support/Code/User/${file}" -ef "${tmp_script_dir}/vscode/${file}" ]
  done
}

@test "[configure-vscode] symlink_vscode_configs: backup of regular file fails" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mock_failure 'backup_if_regular_file'
  mock_echo 'symlink_if_absent'

  run symlink_vscode_configs "${tmp_script_dir}/vscode" "${tmp_dot_home}/Library/Application Support/Code/User"

  assert_failure 1
  refute_line --partial 'symlink_if_absent'
}

@test "[configure-vscode] symlink_vscode_configs: symlink fails" {
  mkdir -p "${tmp_script_dir}/vscode/snippets"
  touch "${tmp_script_dir}/vscode/"{keybindings,settings}.json
  mock_failure 'symlink_if_absent'
  symlink_vscode_configs_with_exit_test() {
    symlink_vscode_configs "${tmp_script_dir}/vscode" "${tmp_dot_home}/Library/Application Support/Code/User"
    echo '[FAILURE] failed to exit'
  }

  run symlink_vscode_configs_with_exit_test

  assert_failure 1
  refute_line '[FAILURE] failed to exit'
}

@test "[configure-vscode] install_vscode_extensions: install multiple extensions" {
  mock_echo 'code'
  mkdir -p "${tmp_script_dir}/vscode"
  printf '%s\n' 'extension-one' 'extension-two' >"${tmp_script_dir}/vscode/extensions"

  run install_vscode_extensions "${tmp_script_dir}/vscode/extensions"

  assert_success
  assert_line 'code --force --install-extension extension-one'
  assert_line 'code --force --install-extension extension-two'
}

@test "[configure-vscode] install_vscode_extensions: install extension fails" {
  mock_failure 'code' '--force' '--install-extension' 'extension-two'
  mkdir -p "${tmp_script_dir}/vscode"
  printf '%s\n' 'extension-one' 'extension-two' 'extension-three' >"${tmp_script_dir}/vscode/extensions"

  run install_vscode_extensions "${tmp_script_dir}/vscode/extensions"

  assert_failure 1
  assert_line 'code --force --install-extension extension-one'
  refute_line 'code --force --install-extension extension-two'
  refute_line 'code --force --install-extension extension-three'
}
