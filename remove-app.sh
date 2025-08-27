#!/bin/bash
set -e

echo "Removing app and all resources (volumes will be deleted)..."

docker rm -f my-webapp my-database || true
docker network rm myapp-network || true
docker volume rm myapp-db-data || true
docker rmi my-flask-app || true

echo "Removal complete."

