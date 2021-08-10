#!/bin/bash

PORT="${PORT:-3306}"

sleep 3
isready=0
for i in {1..10}; do
  echo "Wait for connections to be ready ... $i/10"
  (nc -z 127.0.0.1 $PORT || exit $?) && true # escape bash's pipefail
  isready=$?
  if [[ $isready -eq 0 ]]; then
    break
  fi
  sleep 2
done

# exit with error code if we couldn't connect
if [[ $isready -ne 0 ]]; then
  exit $isready 
fi
