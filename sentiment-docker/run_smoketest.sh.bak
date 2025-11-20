#!/usr/bin/env bash
set -e
IMAGE_NAME="aialpha-sentiment:local"
CONTAINER_ID=$(docker run -d -p 8080:8080 $IMAGE_NAME)
echo "Container started: $CONTAINER_ID"
sleep 6
echo "Health check:"
curl -fsS http://localhost:8080/actuator/health || { echo "Health failed"; docker logs $CONTAINER_ID; exit 1; }
echo "Smoke test OK"
docker stop $CONTAINER_ID
