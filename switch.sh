#!/bin/bash

CURRENT=$(grep -R "server .*8001;" nginx.conf | head -1 | awk '{print $2}')

if [[ "$CURRENT" == "blue:8001;" ]]; then
  sed -i 's/blue:8001;/green:8001;/' nginx.conf
  sed -i 's/green:8001;/blue:8001;/' nginx.conf
  echo "Switched traffic to GREEN"
else
  sed -i 's/green:8001;/blue:8001;/' nginx.conf
  sed -i 's/blue:8001;/green:8001;/' nginx.conf
  echo "Switched traffic to BLUE"
fi

docker exec nginx nginx -s reload
