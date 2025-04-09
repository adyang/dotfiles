#!/bin/bash

if [[ "$(sysctl -n machdep.cpu.brand_string)" =~ 'Apple' ]]; then
  export PATH="/opt/homebrew/bin:${PATH}"
fi
