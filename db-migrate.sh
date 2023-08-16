#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

if [ -e .env ]; then
  export $(grep -v '^#' .env | xargs -0)
fi

if [[ -z "${GOOGLE_CLOUDSQL_SERVICE_ACCOUNT}" || -z "${CLOUDSQL_INSTANCE}" || -z "${DATABASE_NAME}" || -z "${DATABASE_USER}" || -z "${DATABASE_PASSWORD}" ]]; then
  echo -e "${RED}Missing environment variables. GOOGLE_CLOUDSQL_SERVICE_ACCOUNT, CLOUDSQL_INSTANCE, DATABASE_NAME, DATABASE_USER & DATABASE_PASSWORD must exist${NC}"
  exit 1
fi

MIGRATION_SQL_PATH=${MIGRATION_SQL_PATH:-/flyway/sql}
PORT=${PORT:-3306}

echo -e "${GREEN}Saving Cloud SQL JSON Key File!${NC}"
mkdir -p /tmp/gce-cloudsql-proxy
echo $GOOGLE_CLOUDSQL_SERVICE_ACCOUNT > /tmp/gce-cloudsql-proxy/key.json

echo -e "${GREEN}Starting CloudSQL Proxy!${NC}"
/usr/local/sbin/cloud_sql_proxy \
  -credential_file /tmp/gce-cloudsql-proxy/key.json \
  -instances=$CLOUDSQL_INSTANCE=tcp:127.0.0.1:$PORT > /tmp/output.log 2>&1 &
CLOUDSQL_PID=$!
echo -e "${GREEN}CloudSQL Started with PID: $CLOUDSQL_PID!${NC}"

echo -e "${GREEN}Waiting for CloudSQL Proxy to listen on port $PORT!${NC}"
./startup-check.sh
tail /tmp/output.log
SUCCESS=$?
if [[ $SUCCESS -ne 0 ]]; then
  kill -9 $CLOUDSQL_PID
  exit $SUCCESS 
fi

echo -e "${GREEN}Bringing local database up to date!${NC}"

flyway -locations="filesystem:${MIGRATION_SQL_PATH}" -url=jdbc:mysql://127.0.0.1:3306/$DATABASE_NAME -user="$DATABASE_USER" -password="$DATABASE_PASSWORD" migrate
if [ $? -ne 0 ]; then
  echo -e "${RED}DB Migration failed! - Repairing DB after failed migration!${NC}"
  flyway -locations="filesystem:${MIGRATION_SQL_PATH}" -url=jdbc:mysql://127.0.0.1:3306/$DATABASE_NAME -user="$DATABASE_USER" -password="$DATABASE_PASSWORD" repair
  kill -9 $CLOUDSQL_PID
  exit 1
fi
kill -9 $CLOUDSQL_PID

echo -e "${GREEN}Database is now up to date!${NC}"
