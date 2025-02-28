#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'mock_helper'

setup() {
  tmp_dot_home="$(mktemp -d)"
  DOT_HOME="${tmp_dot_home}"
  tmp_script_dir="$(mktemp -d)"
  source "${BATS_TEST_DIRNAME}/../configure-firefox"
}

teardown() {
  rm -rf "${tmp_dot_home}"
  rm -rf "${tmp_script_dir}"
}

@test "[configure-firefox] create_firefox_profile_if_absent: profile absent" {
  mock_echo 'firefox'
  mock_echo 'sleep'
  mock_echo 'kill'
  mkdir -p "${tmp_script_dir}/firefox"
  echo 'profiles' >"${tmp_script_dir}/firefox/profiles.ini"
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox"

  run create_firefox_profile_if_absent 'firefox' "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox"

  assert_success
  assert_line "firefox -CreateProfile privacy ${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"
  assert_equal "$(cat "${tmp_dot_home}/Library/Application Support/Firefox/profiles.ini")" 'profiles'
  assert_line "firefox --headless -P privacy"
}

@test "[configure-firefox] create_firefox_profile_if_absent: profile present" {
  mock_echo 'firefox'
  mock_echo 'sleep'
  mock_echo 'kill'
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"

  run create_firefox_profile_if_absent 'firefox' "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox"

  assert_success
  refute_line --partial 'firefox -CreateProfile'
}

@test "[configure-firefox] create_firefox_profile_if_absent: create profile fails" {
  mock_failure 'firefox' '-CreateProfile'
  mock_echo 'cp'
  mock_echo 'sleep'
  mock_echo 'kill'
  mkdir -p "${tmp_script_dir}/firefox"
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox"

  run create_firefox_profile_if_absent 'firefox' "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox"

  assert_failure 1
  refute_line --partial 'cp'
}

@test "[configure-firefox] create_firefox_profile_if_absent: copying profiles.ini fails" {
  mock_failure 'cp'
  mock_echo 'firefox'
  mock_echo 'sleep'
  mock_echo 'kill'
  mkdir -p "${tmp_script_dir}/firefox"
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox"

  run create_firefox_profile_if_absent 'firefox' "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox"

  assert_failure 1
  refute_line --partial 'firefox --headless'
}

@test "[configure-firefox] symlink_firefox_configs: updater.sh and user-overrides.js absent" {
  mkdir -p "${tmp_script_dir}/firefox/arkenfox"
  touch "${tmp_script_dir}/firefox/arkenfox"/{updater.sh,user-overrides.js,prefsCleaner.sh}
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"

  run symlink_firefox_configs "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"

  assert_success
  assert [ "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/updater.sh" -ef "${tmp_script_dir}/firefox/arkenfox/updater.sh" ]
  assert [ "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/user-overrides.js" -ef "${tmp_script_dir}/firefox/arkenfox/user-overrides.js" ]
}

@test "[configure-firefox] symlink_firefox_configs: updater.sh and user-overrides.js present" {
  mkdir -p "${tmp_script_dir}/firefox/arkenfox"
  touch "${tmp_script_dir}/firefox/arkenfox"/{updater.sh,user-overrides.js,prefsCleaner.sh}
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"
  echo 'updater.sh' >"${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/updater.sh"
  echo 'user-overrides.js' >"${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/user-overrides.js"

  run symlink_firefox_configs "${tmp_script_dir}/firefox" "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy"

  assert_success
  assert_equal "$(cat "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/updater.sh.bak")" 'updater.sh'
  assert_equal "$(cat "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/user-overrides.js.bak")" 'user-overrides.js'
  assert [ "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/updater.sh" -ef "${tmp_script_dir}/firefox/arkenfox/updater.sh" ]
  assert [ "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/user-overrides.js" -ef "${tmp_script_dir}/firefox/arkenfox/user-overrides.js" ]
}

@test "[configure-firefox] install_firefox_extensions: install multiple extensions" {
  mock_echo 'install_firefox_extension_if_absent'
  mkdir -p "${tmp_script_dir}/firefox"
  printf '%s\n' 'https://firefox.com/'{extension-one,extension-two} >"${tmp_script_dir}/firefox/extensions"

  run install_firefox_extensions "${tmp_script_dir}/firefox/extensions" "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_success
  for extension in extension-one extension-two; do
    assert_line "install_firefox_extension_if_absent https://firefox.com/${extension} ${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions ${tmp_dot_home}"
  done
}

@test "[configure-firefox] install_firefox_extensions: install extension fails" {
  mock_failure 'install_firefox_extension_if_absent'
  mkdir -p "${tmp_script_dir}/firefox"
  printf '%s\n' 'https://firefox.com/'{extension-one,extension-two} >"${tmp_script_dir}/firefox/extensions"

  run install_firefox_extensions "${tmp_script_dir}/firefox/extensions" "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_failure 1
  refute_line --partial 'extension-two'
}

@test "[configure-firefox] install_firefox_extension_if_absent: extension absent" {
  obtain_firefox_extension_info() {
    printf '%s\n' 'extension-id' 'extension-name' 'download-url' 'checksum'
    printf '\0'
  }
  download_firefox_extension() {
    local dest="$2"
    touch "${dest}"
    echo "download_firefox_extension $*"
  }
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions"
  touch "${tmp_dot_home}/extension"

  run install_firefox_extension_if_absent 'extension-meta-url' "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_success
  assert_line "download_firefox_extension download-url ${tmp_dot_home}/extension-id checksum"
  assert [ -e "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions/extension-id.xpi" ]
}

@test "[configure-firefox] install_firefox_extension_if_absent: extension present" {
  obtain_firefox_extension_info() {
    printf '%s\n' 'extension-id' 'extension-name' 'download-url' 'checksum'
    printf '\0'
  }
  mock_echo 'download_firefox_extension'
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions"
  touch "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions/extension-id.xpi"
  touch "${tmp_dot_home}/extension"

  run install_firefox_extension_if_absent 'extension-meta-url' "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_success
  assert_line --partial 'extension-name already exists'
  refute_line --partial 'download_firefox_extension'
}

@test "[configure-firefox] install_firefox_extension_if_absent: obtaining extension info fails" {
  mock_failure 'obtain_firefox_extension_info'
  mock_echo 'download_firefox_extension'
  mock_echo 'mv'
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions"
  touch "${tmp_dot_home}/extension"

  run install_firefox_extension_if_absent 'extension-meta-url' "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_failure 1
  refute_line --partial 'download_firefox_extension'
}

@test "[configure-firefox] install_firefox_extension_if_absent: download extension fails" {
  obtain_firefox_extension_info() {
    printf '%s\n' 'extension-id' 'extension-name' 'download-url' 'checksum'
    printf '\0'
  }
  mock_failure 'download_firefox_extension'
  mock_echo 'mv'
  mkdir -p "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions"
  touch "${tmp_dot_home}/extension"

  run install_firefox_extension_if_absent 'extension-meta-url' "${tmp_dot_home}/Library/Application Support/Firefox/Profiles/privacy/extensions" "${tmp_dot_home}"

  assert_failure 1
  refute_line --partial 'mv'
}

@test "[configure-firefox] obtain_firefox_extension_info: all information present" {
  curl() {
    if [[ "$*" != *'meta-url'* ]]; then return 1; fi
    printf '%s\n' '{"guid":"extension-id","name":{"en-US":"extension-name"},"current_version":{"files":[{"url":"download-url","hash":"checksum"}]}}'
  }

  run obtain_firefox_extension_info 'meta-url'

  assert_success
  assert_line --index 0 'extension-id'
  assert_line --index 1 'extension-name'
  assert_line --index 2 'download-url'
  assert_line --index 3 'checksum'
}

@test "[configure-firefox] obtain_firefox_extension_info: some information absent" {
  curl() {
    if [[ "$*" != *'meta-url'* ]]; then return 1; fi
    printf '%s\n' '{"name":{"en-US":"extension-name"}}'
  }

  run obtain_firefox_extension_info 'meta-url'

  assert_failure 1
  assert_line --partial 'missing extension info'
}

@test "[configure-firefox] obtain_firefox_extension_info: extension info retrieval fails" {
  mock_failure 'curl'
  mock_echo 'jq'

  run obtain_firefox_extension_info 'meta-url'

  assert_failure 1
  refute_line --partial 'jq'
}

@test "[configure-firefox] download_firefox_extension: download fails" {
  mock_failure 'curl'
  mock_echo 'gsha256sum'

  run download_firefox_extension 'download-url' "${tmp_dot_home}/extension-id"

  assert_failure 1
  refute_line --partial 'gsha256sum'
}

@test "[configure-firefox] download_firefox_extension: checksum succeeds" {
  printf 'extension' > "${tmp_dot_home}/extension-download"
  checksum="$(gsha256sum "${tmp_dot_home}/extension-download")"
  curl() {
    local dest="$5"
    mv "${tmp_dot_home}/extension-download" "${dest}"
  }

  run download_firefox_extension 'download-url' "${tmp_dot_home}/extension-id" "sha256:${checksum% *}"

  assert_success
  assert_equal "$(cat "${tmp_dot_home}/extension-id")" 'extension'
}

@test "[configure-firefox] download_firefox_extension: checksum fails" {
  curl() {
    local dest="$5"
    touch "${dest}"
  }

  run download_firefox_extension 'download-url' "${tmp_dot_home}/extension-id" "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

  assert_failure 1
  assert_line --partial 'FAILED'
}
