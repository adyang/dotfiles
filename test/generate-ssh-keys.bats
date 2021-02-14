#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

readonly GENERATE_SSH_KEYS="${BATS_TEST_DIRNAME}/../generate-ssh-keys"

setup() {
  tmp_gen_ssh_home="$(mktemp -d)"
  mkdir "${tmp_gen_ssh_home}/.ssh"
  export GEN_SSH_HOME="${tmp_gen_ssh_home}"

  expect() {
    cat
  }
  export -f expect
}

teardown() {
  rm -rf "${tmp_gen_ssh_home}"
}

@test "[generate-ssh-keys] generate SSH keys when --key-filename option is absent" {
  run "${GENERATE_SSH_KEYS}" <<<'pass'

  assert_success
  assert [ -f "${tmp_gen_ssh_home}/.ssh/id_ed25519" ]
  assert [ -f "${tmp_gen_ssh_home}/.ssh/id_ed25519.pub" ]
}

@test "[generate-ssh-keys] generate SSH keys when --key-filename option is present" {
  run "${GENERATE_SSH_KEYS}" --key-filename id_test <<<'pass'

  assert_success
  assert [ -f "${tmp_gen_ssh_home}/.ssh/id_test" ]
  assert [ -f "${tmp_gen_ssh_home}/.ssh/id_test.pub" ]
}

@test "[generate-ssh-keys] invalid option" {
  run "${GENERATE_SSH_KEYS}" --invalid-option

  assert_failure 2
  assert_line --index 1 --partial "Invalid option: '--invalid-option'"
  assert_line --index 2 --partial 'usage: ./generate-ssh-keys [--key-filename <private-key-filename>]'
}

@test "[generate-ssh-keys] add SSH key identity to agent" {
  run "${GENERATE_SSH_KEYS}" <<<'pass'

  assert_success
  assert_line --partial "ssh-add -K \"${GEN_SSH_HOME}/.ssh/id_ed25519\""
  assert_line --partial 'send -- "pass\r"'
}

@test "[generate-ssh-keys] empty passphrase" {
  run "${GENERATE_SSH_KEYS}" <<<$'\n'

  assert_failure
  refute_line --partial "ssh-add -K \"${GEN_SSH_HOME}/.ssh/id_ed25519\""
}

@test "[generate-ssh-keys] read fails" {
  read() {
    return 1
  }
  ssh-keygen() {
    echo "ssh-keygen $*"
  }
  export -f read ssh-keygen

  run "${GENERATE_SSH_KEYS}" <<<'pass'

  assert_failure 1
  refute_line --partial "ssh-keygen"
}

@test "[generate-ssh-keys] ssh-keygen fails" {
  ssh-keygen() {
    return 1
  }
  export -f ssh-keygen

  run "${GENERATE_SSH_KEYS}" <<<'pass'

  assert_failure 1
  refute_line --partial "ssh-add -K \"${GEN_SSH_HOME}/.ssh/id_ed25519\""
}

@test "[generate-ssh-keys] add key identity to agent fails" {
  expect() {
    return 1
  }
  pbcopy() {
    '[FAILURE] failed to exit'
  }
  export -f pbcopy

  run "${GENERATE_SSH_KEYS}" <<<'pass'

  assert_failure 1
  refute_line --partial '[FAILURE] failed to exit'
}
