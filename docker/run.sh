#!/bin/sh
DOCKER_IMAGE=${DOCKER_IMAGE:-gcu-dev}
netlify_config=~/.config/netlify
ssh_socket=${SSH_AUTH_SOCK:-~/.ssh/agent.sock}
workdir=~/workarea/gcu
if [ -d ${workdir} ]; then
  workdir_opt="-v ${workdir}:${workdir}"
fi

exec </dev/tty
docker run -it --rm \
  --hostname ${DOCKER_IMAGE} \
  -p 1111:1111 \
  -v ${netlify_config}:${netlify_config} \
  -v ${ssh_socket}:${ssh_socket} \
  -e SSH_AUTH_SOCK=${ssh_socket} \
  ${workdir_opt} \
  yacoob/${DOCKER_IMAGE}
