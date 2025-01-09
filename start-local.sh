#!/bin/bash
set -euo pipefail

echo "🧹 Cleaning up any existing containers..."
docker stop depwatch 2>/dev/null || true
docker rm depwatch 2>/dev/null || true
docker rmi depwatch:latest 2>/dev/null || true

#echo "🔨 Building the application..."
#bazel build //...

#echo "🔨 Building the container image..."
#bazel build //docker:tarball

echo "🐳 Loading the container image into Docker..."
docker load < bazel-bin/docker/tarball/tarball.tar

# Add debugging information
echo "📋 Current Docker images:"
docker images

# More detailed image verification
echo "🔍 Verifying image is loaded..."
if docker images depwatch:latest --format "{{.Repository}}:{{.Tag}}" | grep -q "^depwatch:latest$"; then
    echo "✅ Image depwatch:latest found"
else
    echo "❌ Image depwatch:latest not found"
    echo "Available images:"
    docker images
    exit 1
fi

echo "🚀 Starting the application container..."
sleep 2

docker run -d \
    --name depwatch \
    -p 9090:9090 \
    --pull never \
    depwatch:latest

echo "⏳ Waiting for application to start..."
sleep 5

# Check container status
container_status=$(docker inspect -f '{{.State.Status}}' depwatch)
if [ "$container_status" != "running" ]; then
    echo "❌ Container is not running. Status: $container_status"
    echo "Container logs:"
    docker logs depwatch
    exit 1
fi

echo "🔍 Testing health endpoint..."
max_retries=12
for ((i=1; i<=max_retries; i++)); do
    if curl -s http://localhost:9090/health > /dev/null; then
        echo "✅ Health check successful"
        break
    fi
    if [ $i -eq $max_retries ]; then
        echo "❌ Failed to connect to health endpoint after $max_retries attempts"
        echo "Container logs:"
        docker logs depwatch
        exit 1
    fi
    echo "Waiting for application to start... (attempt $i/$max_retries)"
    sleep 5
done

echo -e "\n✨ Application is running!"
echo "Health check: http://localhost:9090/health"
echo "Version check: http://localhost:9090/version"
echo ""
echo "To view logs:"
echo "docker logs depwatch"
echo ""
echo "To stop the container, run:"
echo "./cleanup-local.sh"

