#!/bin/bash

# deploy.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Your Docker Hub Username
DOCKER_HUB_USERNAME="arundiv" # REPLACE with your Docker Hub username

# Application Name (used for image name)
APP_NAME="devops-build-app"

# EC2 Application Server Public IP
APP_SERVER_PUBLIC_IP="3.110.47.64" # REPLACE with your EC2 app server's Public IP

# Path to your SSH private key on the machine running this script (e.g., Jenkins server or local)
SSH_KEY_PATH="my-devops-server.pem" # REPLACE with the path to your .pem file

# Determine the image tag based on the branch (this script will be run after build.sh context)
# In a Jenkins pipeline, the image name would be passed as a parameter.
# For manual testing, assume it's the prod image after master merge
IMAGE_TAG="prod" # Assuming this script deploys the 'prod' image
DOCKER_REPO="$DOCKER_HUB_USERNAME/$APP_NAME-$IMAGE_TAG"

# --- Deployment Process ---
echo "Deploying Docker image $DOCKER_REPO:$IMAGE_TAG to $APP_SERVER_PUBLIC_IP"

# Ensure the SSH key has correct permissions
chmod 400 "$SSH_KEY_PATH"

# SSH into the EC2 instance, pull the new image, and restart the service
# The 'HERE_DOC' syntax allows running multiple commands on the remote server.
ssh -i "$SSH_KEY_PATH" ubuntu@"$APP_SERVER_PUBLIC_IP" << EOF
  echo "Logged into remote server. Pulling new image..."
  docker login -u "$DOCKER_HUB_USERNAME" -p "$DOCKER_HUB_PASSWORD_OR_TOKEN" # Use environment variable for password/token for security

  # Pull the latest image
  docker pull "$DOCKER_REPO:$IMAGE_TAG"

  echo "Stopping existing container and recreating with new image..."
  # Navigate to the application directory on the remote server
  cd ~/devops-build # Assuming your app is cloned here

  # Update the docker-compose.yml to use the specific image from Docker Hub
  # This dynamically updates the image used by docker-compose for consistent deployment
  sed -i "s|image: .*|image: $DOCKER_REPO:$IMAGE_TAG|" docker-compose.yml

  # Stop and remove existing containers, then start new ones with the updated image
  docker-compose down || true # '|| true' prevents script from failing if container is not running
  docker-compose up -d

  echo "Deployment complete."
EOF

echo "Deployment script finished."
