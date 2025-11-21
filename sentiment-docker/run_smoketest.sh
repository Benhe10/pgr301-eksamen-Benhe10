#!/usr/bin/env bash
set -euo pipefail

# Use IMAGE environment variable if provided. Default fallback:
IMAGE="${IMAGE:-aialpha-sentiment:local}"
CONTAINER_NAME="${CONTAINER_NAME:-aialpha-sentiment-local}"

echo "Using image: $IMAGE"
echo "Starting container: $CONTAINER_NAME"

# remove existing container if present
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run container in background
docker run -d -p 8080:8080 \
  -e MANAGEMENT_METRICS_EXPORT_CLOUDWATCH_ENABLED=false \
  --name "$CONTAINER_NAME" \
  "$IMAGE"

# Wait for health endpoint
for i in {1..12}; do
  echo "Attempt $i ..."
  if curl -fsS http://127.0.0.1:8080/actuator/health > /tmp/health.json 2>/dev/null; then
    echo "Health OK:"
    cat /tmp/health.json
    echo "Smoke test OK"
    exit 0
  else
    echo "Not ready yet, sleeping 2s"
    sleep 2
  fi
done

echo "Container logs (last 200 lines):"
docker logs --tail 200 "$CONTAINER_NAME" || true

echo "Smoke test FAILED" >&2
exit 1
