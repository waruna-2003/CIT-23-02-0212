#!/bin/bash
set -e

DB_CONTAINER="my-database"
WEB_CONTAINER="my-webapp"
NETWORK="myapp-network"
VOLUME="myapp-db-data"
WEB_IMAGE="my-flask-app"

# Credentials (change if you want)
DB_ROOT_PASS="rootpass"
DB_NAME="mydb"
DB_USER="myuser"
DB_PASS="mypassword"

HOST_WEB_PORT=5000   # host port for web
HOST_DB_PORT=3306    # host port for db (change if conflicts)

echo "Starting application..."

# Start DB container if not present
if [ "$(docker ps -a -q -f name=^/${DB_CONTAINER}$)" ]; then
  echo "DB container exists — starting it"
  docker start ${DB_CONTAINER}
else
  docker run -d --name ${DB_CONTAINER} \
    --network ${NETWORK} \
    -e MYSQL_ROOT_PASSWORD=${DB_ROOT_PASS} \
    -e MYSQL_DATABASE=${DB_NAME} \
    -e MYSQL_USER=${DB_USER} \
    -e MYSQL_PASSWORD=${DB_PASS} \
    -v ${VOLUME}:/var/lib/mysql \
    -p ${HOST_DB_PORT}:3306 \
    --restart unless-stopped \
    mysql:8.0
fi

# Wait for MySQL readiness
echo "Waiting for MySQL to be ready..."
until docker exec ${DB_CONTAINER} mysqladmin ping -uroot -p${DB_ROOT_PASS} --silent &>/dev/null; do
  sleep 1
done
echo "MySQL is ready."

# Start web container
if [ "$(docker ps -a -q -f name=^/${WEB_CONTAINER}$)" ]; then
  echo "Web container exists — starting it"
  docker start ${WEB_CONTAINER}
else
  docker run -d --name ${WEB_CONTAINER} \
    --network ${NETWORK} \
    -e DB_HOST=${DB_CONTAINER} \
    -e DB_USER=${DB_USER} \
    -e DB_PASSWORD=${DB_PASS} \
    -e DB_NAME=${DB_NAME} \
    -p ${HOST_WEB_PORT}:5000 \
    --restart unless-stopped \
    ${WEB_IMAGE}
fi

echo "Application started."
echo "Access the app at: http://localhost:${HOST_WEB_PORT}"

