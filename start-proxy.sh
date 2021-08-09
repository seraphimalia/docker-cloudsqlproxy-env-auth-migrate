#!/bin/bash

PORT="${PORT:-3306}"

# write google application credentials to a temporary file to be used inside the container
mkdir -p /tmp/gce-cloudsql-proxy
echo $GOOGLE_CLOUDSQL_SERVICE_ACCOUNT > /tmp/gce-cloudsql-proxy/key.json

# start container
./cloud_sql_proxy \
  -credential_file /tmp/gce-cloudsql-proxy/key.json \
  -dir /tmp \
  -instances=$CLOUDSQL_INSTANCE=tcp:127.0.0.1:$PORT
