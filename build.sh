#!/bin/bash

# build.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Your Docker Hub Username
DOCKER_HUB_USERNAME="arundiv" # This line should remain

# Application Name (used for image name)
APP_NAME="devops-build-app"

# Get the current Git branch name
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Determine the image tag based on the branch
if [[ "$GIT_BRANCH" == "dev" ]]; then
  IMAGE_TAG="dev"
  DOCKER_REPO="$DOCKER_HUB_USERNAME/$APP_NAME-dev" # Dev repo
elif [[ "$GIT_BRANCH" == "master" ]]; then
  IMAGE_TAG="prod" # Or use a version like v1.0.0 for prod
  DOCKER_REPO="$DOCKER_HUB_USERNAME/$APP_NAME-prod" # Prod repo
else
  # For any other branch, use the branch name as tag and dev repo
  IMAGE_TAG="$GIT_BRANCH"
  DOCKER_REPO="$DOCKER_HUB_USERNAME/$APP_NAME-dev"
fi

# --- Build Process ---
echo "Building Docker image for branch: $GIT_BRANCH"
echo "Image will be tagged as: $DOCKER_REPO:$IMAGE_TAG"

# Build the Docker image
# The '.' means build from the current directory (where Dockerfile is located)
docker build -t "$DOCKER_REPO:$IMAGE_TAG" .

echo "Docker image built successfully: $DOCKER_REPO:$IMAGE_TAG"

# Optional: Push the image directly (will be done by Jenkins for automation)
# docker push "$DOCKER_REPO:$IMAGE_TAG"
