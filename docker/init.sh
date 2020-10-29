#!/bin/sh
set -x
# install netlify large media hooks
netlify lm:install
# re-run the shell to pick up the PATH change
exec /usr/bin/zsh
