#!/bin/bash
set -e

echo "Stopping app..."

docker stop my-webapp || true
docker stop my-database || true

echo "Stopped. Persistent data remains in the named volume."

