#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "${BATS_TEST_DIRNAME}/../install" 

@test "sudo_keep_alive: password validation failure" {
  sudo_until_process_ends() {
    echo '[FAILURE] should exit immediately on sudo validation failure'
  }

  run sudo_keep_alive <<< $'wrong\nwrong\nwrong\n'

  assert_failure 1
  refute_output --partial '[FAILURE]'
}

