source /usr/local/opt/asdf/asdf.sh

if asdf current java >/dev/null 2>&1; then
  asdf_java_path="$(asdf which java)"
  export JAVA_HOME="${asdf_java_path%/*/*}"
  unset -v asdf_java_path
fi
