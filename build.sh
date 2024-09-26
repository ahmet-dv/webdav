#!/bin/bash

# Script to build, tag, and push Docker image to DockerHub

# Ensure script exits on error
set -ex

# Variables (you can modify these)
DOCKER_USERNAME="dockdv"  # Replace with your DockerHub username
DOCKER_REPO_NAME="webdav"          # Replace with your DockerHub repository name
IMAGE_TAGS=("latest" "v0.2.0")      # Add more tags here

# Full image name (without tag) on DockerHub
IMAGE_NAME="$DOCKER_USERNAME/$DOCKER_REPO_NAME"

# Step 1: Build the Docker image with one base tag
echo "Building the Docker image..."
#docker build -t "$IMAGE_NAME:${IMAGE_TAGS[0]}" .
docker build --no-cache --progress=plain -t "$IMAGE_NAME:${IMAGE_TAGS[0]}" . 2>&1 | tee build.log

# Step 2: Login to DockerHub (optional, if you're already logged in, you can skip this)
#echo "Logging in to DockerHub..."
#docker login -u "$DOCKER_USERNAME"

# Step 3: Tag the image with multiple tags and push each tag
for TAG in "${IMAGE_TAGS[@]}"; do
    FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"
    echo "Tagging the image as $FULL_IMAGE_NAME"
    docker tag "$IMAGE_NAME:${IMAGE_TAGS[0]}" "$FULL_IMAGE_NAME"

    #echo "Pushing the image to DockerHub with tag: $TAG"
    #docker push "$FULL_IMAGE_NAME"
done

# Step 4: Confirm the image was pushed successfully with all tags
#echo "Docker image pushed successfully with tags: ${IMAGE_TAGS[*]}"

