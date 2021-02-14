#!/bin/bash

header() {
  printf '\033[00;34m%s\033[0m\n' "*** $1 ***"
}

sub_header() {
  printf '\033[00;34m%s\033[0m\n' "* $1"
}

note() {
  printf '\033[0;33m%s\033[0m\n' "$*"
}

err() {
  printf '\033[0;31m%s\033[0m\n' "$*" >&2
}
