#!/bin/sh
netlify_config=~/.config/netlify
ssh_socket=~/.ssh/agent.sock
workdir=~/workarea/gcu
if [ -d ${workdir} ]; then
  workdir_opt="-v ${workdir}:${workdir}"
fi

docker run -it --rm \
  --hostname gcu-dev \
  -p 1111:1111 \
  -v ${netlify_config}:${netlify_config} \
  -v ${ssh_socket}:${ssh_socket} \
  -e SSH_AUTH_SOCK=${ssh_socket} \
  ${workdir_opt} \
  yacoob/gcu-dev
