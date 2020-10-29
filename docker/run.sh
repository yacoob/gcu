#!/bin/sh
docker run -it --rm \
  --hostname gcu-dev \
  #-v /home/yacoob/.netlify:/home/yacoob/.netlify \
  #-v /home/yacoob/workarea/gcu:/home/yacoob/workarea/gcu \
  yacoob/gcu-dev
