# Script to build, tag, and push Docker image to DockerHub with multiple tags

# Ensure script exits on error
$ErrorActionPreference = "Stop"

# Variables (customize these)
$DOCKER_USERNAME = "dockdv"  # Replace with your DockerHub username
$DOCKER_REPO_NAME = "webdav"          # Replace with your DockerHub repository name
$IMAGE_TAGS = @("latest", "v0.2.0")   # Add more tags here

# Full image name (without tag) on DockerHub
$IMAGE_NAME = "$DOCKER_USERNAME/$DOCKER_REPO_NAME"

# Step 1: Build the Docker image with the first tag
Write-Host "Building the Docker image..."
docker build -t "${IMAGE_NAME}:${IMAGE_TAGS[0]}" .

# Step 2: Login to DockerHub (optional, if you're already logged in, you can skip this)
Write-Host "Logging in to DockerHub..."
docker login -u $DOCKER_USERNAME

# Step 3: Tag the image with multiple tags and push each tag
foreach ($TAG in $IMAGE_TAGS) {
    $FULL_IMAGE_NAME = "${IMAGE_NAME}:$TAG"
    Write-Host "Tagging the image as $FULL_IMAGE_NAME"
    docker tag "${IMAGE_NAME}:${IMAGE_TAGS[0]}" "$FULL_IMAGE_NAME"

    Write-Host "Pushing the image to DockerHub with tag: $TAG"
    docker push "$FULL_IMAGE_NAME"
}

# Step 4: Confirm the image was pushed successfully with all tags
Write-Host "Docker image pushed successfully with tags: $($IMAGE_TAGS -join ', ')"
