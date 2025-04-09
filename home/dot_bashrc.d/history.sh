#!/bin/bash

HISTFILESIZE=100000
HISTSIZE=10000
HISTCONTROL='ignoreboth'

PROMPT_COMMAND="${PROMPT_COMMAND:-:}; history -a"

shopt -s histappend

