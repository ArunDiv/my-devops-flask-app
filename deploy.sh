#!/bin/bash

# deploy.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
DOCKER_COMPOSE_FILE="docker-compose.yml" # Path to your docker-compose file

# Get the Docker image name with tag from the first argument passed to this script
APP_IMAGE_FULL_NAME="$1"

if [ -z "$APP_IMAGE_FULL_NAME" ]; then
    echo "Usage: ./deploy.sh <docker_image_name_with_tag>"
    exit 1
fi

echo "Attempting to deploy image: $APP_IMAGE_FULL_NAME"

# Stop and remove existing services defined in docker-compose.yml
echo "Stopping and removing existing services defined in $DOCKER_COMPOSE_FILE..."
# '|| true' prevents script from exiting if services aren't running (e.g., first deployment)
docker-compose -f "$DOCKER_COMPOSE_FILE" down || true

# Pull the specified image from Docker Hub
echo "Pulling image: $APP_IMAGE_FULL_NAME"
docker pull "$APP_IMAGE_FULL_NAME"

# Deploy the application using docker-compose, setting the APP_IMAGE_FULL_NAME environment variable
echo "Starting new services with image: $APP_IMAGE_FULL_NAME"
APP_IMAGE_FULL_NAME="$APP_IMAGE_FULL_NAME" docker-compose -f "$DOCKER_COMPOSE_FILE" up -d

echo "Deployment complete for $APP_IMAGE_FULL_NAME."
