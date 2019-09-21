#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

readonly IMPORT_GPG_KEYS="${BATS_TEST_DIRNAME}/../import-gpg-keys"

setup() {
  tmpdir="$(mktemp -d)"
  mkdir -p "${tmpdir}"/{gen,test}

  export GNUPGHOME="${tmpdir}/gen"
  generate_test_keys
  export_test_files "${tmpdir}/public.asc" "${tmpdir}/secret.asc" "${tmpdir}/ownertrust.asc"
}

generate_test_keys() {
  local status
  status="$(gpg --batch --status-fd 1 --passphrase 'test' --quick-generate-key 'testUser' rsa4096)"
  keyid="${status##*KEY_CREATED P }"
}

export_test_files() {
  public_key="$1"
  secret_key="$2"
  ownertrust="$3"
  gpg --export --output "${public_key}" --armor "${keyid}"
  gpg --batch --pinentry-mode loopback --passphrase 'test' --export-secret-keys --output "${secret_key}" --armor "${keyid}"
  gpg --export-ownertrust > "${ownertrust}"
}

teardown() {
  rm -rf "${tmpdir}"
}

@test "[import-gpg-keys] no options provided" {
  run "${IMPORT_GPG_KEYS}"

  assert_failure 2
  assert_output "\
usage: ./import-gpg-keys [--public-key <public-key-file>]
                         [--secret-key <secret-key-file>]
                         [--ownertrust <ownertrust-file>]"
}

@test "[import-gpg-keys] no options but unexpected arguments provided" {
  run "${IMPORT_GPG_KEYS}" unexpected arguments

  assert_failure 2
  assert_line --index 0 --partial 'usage'
}

@test "[import-gpg-keys] invalid option" {
  run "${IMPORT_GPG_KEYS}" --invalid-option

  assert_failure 2
  assert_line --index 0 "Invalid option: '--invalid-option'"
  assert_line --index 1 --partial 'usage'
}

@test "[import-gpg-keys] public-key option provided: public-key-file value absent" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --public-key

  assert_failure 2
  assert_line --index 0 "Invalid value for '--public-key': '' is not a valid file or does not exists"
  assert_line --index 1 --partial 'usage'
}

@test "[import-gpg-keys] public-key option provided: public-key-file value does not exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --public-key non-existent-file

  assert_failure 2
  assert_line --index 0 "Invalid value for '--public-key': 'non-existent-file' is not a valid file or does not exists"
  assert_line --index 1 --partial 'usage'
}

@test "[import-gpg-keys] public-key option provided: public-key-file exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --public-key "${public_key}"

  assert_success
  run gpg --list-keys --keyid-format long "${keyid}"
  assert_success
  assert_line --partial 'pub'
  assert_line --partial "${keyid}"
}

@test "[import-gpg-keys] secret-key option provided: secret-key-file value does not exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --secret-key non-existent-file

  assert_failure 2
  assert_line --index 0 "Invalid value for '--secret-key': 'non-existent-file' is not a valid file or does not exists"
  assert_line --index 1 --partial 'usage'
}

@test "[import-gpg-keys] secret-key option provided: secret-key-file exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --secret-key "${secret_key}"

  assert_success
  run gpg --list-secret-keys --keyid-format long "${keyid}"
  assert_success
  assert_line --partial 'sec'
  assert_line --partial "${keyid}"
}

@test "[import-gpg-keys] ownertrust option provided: ownertrust-file value does not exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --ownertrust non-existent-file

  assert_failure 2
  assert_line --index 0 "Invalid value for '--ownertrust': 'non-existent-file' is not a valid file or does not exists"
  assert_line --index 1 --partial 'usage'
}

@test "[import-gpg-keys] ownertrust option provided: ownertrust-file exists" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --ownertrust "${ownertrust}"

  assert_success
  run gpg --export-ownertrust
  assert_success
  assert_line "${keyid}:6:"
}

@test "[import-gpg-keys] 2 options provided: --public-key and --ownertrust" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --ownertrust "${ownertrust}" --public-key "${public_key}"

  assert_success
  run gpg --export-ownertrust
  assert_success
  assert_line "${keyid}:6:"
  run gpg --list-keys --keyid-format long "${keyid}"
  assert_success
  assert_line --partial 'pub'
  assert_line --partial "${keyid}"
}

@test "[import-gpg-keys] all options provided" {
  export GNUPGHOME="${tmpdir}/test"

  run "${IMPORT_GPG_KEYS}" --secret-key "${secret_key}" --ownertrust "${ownertrust}" --public-key "${public_key}"

  assert_success
  run gpg --list-secret-keys --keyid-format long "${keyid}"
  assert_success
  assert_line --partial 'sec'
  assert_line --partial "${keyid}"
  run gpg --export-ownertrust
  assert_success
  assert_line "${keyid}:6:"
  run gpg --list-keys --keyid-format long "${keyid}"
  assert_success
  assert_line --partial 'pub'
  assert_line --partial "${keyid}"
}

