#!/bin/bash
set -euo pipefail

echo "🛑 Stopping the application container..."
docker stop depwatch || true
docker rm depwatch || true

echo "🧹 Cleaning up Docker images..."
docker rmi depwatch:latest || true

#echo "🧹 Cleaning Bazel cache..."
#bazel clean --expunge

echo "✨ Cleanup complete!"