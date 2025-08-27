#!/bin/bash
set -e

echo "Preparing app..."

NETWORK="myapp-network"
VOLUME="myapp-db-data"
WEB_IMAGE="my-flask-app"

# Create network if not exists
if ! docker network inspect $NETWORK >/dev/null 2>&1; then
  docker network create $NETWORK
  echo "Created network: $NETWORK"
else
  echo "Network $NETWORK already exists"
fi

# Create volume if not exists
if ! docker volume inspect $VOLUME >/dev/null 2>&1; then
  docker volume create $VOLUME
  echo "Created volume: $VOLUME"
else
  echo "Volume $VOLUME already exists"
fi

# Build web image
docker build -t $WEB_IMAGE ./app
echo "Built image: $WEB_IMAGE"

echo "Prepare complete."

