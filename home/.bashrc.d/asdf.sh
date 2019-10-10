source /usr/local/opt/asdf/asdf.sh
source "${HOME}/.asdf/plugins/java/set-java-home.sh"

if asdf current java >/dev/null 2>&1; then
  export JAVA_HOME="$(asdf which java)"
fi
