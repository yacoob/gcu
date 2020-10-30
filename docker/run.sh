#!/bin/sh
docker run -it --rm \
  --hostname gcu-dev \
  -p 1111:1111 \
  -v /home/yacoob/.netlify:/home/yacoob/.netlify \
  -v /home/yacoob/.ssh:/home/yacoob/.ssh:ro \
  -e SSH_AUTH_SOCK=/home/yacoob/.ssh/agent.sock \
  yacoob/gcu-dev
  #-v /home/yacoob/workarea/gcu:/home/yacoob/workarea/gcu \
