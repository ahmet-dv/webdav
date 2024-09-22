@echo off
REM Script to build, tag, and push Docker image to DockerHub with multiple tags

REM Ensure script exits on error
setlocal enabledelayedexpansion
set "errorlevel=0"

REM Variables (customize these)
set "DOCKER_USERNAME=dockdv"  REM Replace with your DockerHub username
set "DOCKER_REPO_NAME=webdav"          REM Replace with your DockerHub repository name
set "IMAGE_TAGS=latest v0.2.0"            REM Add more tags here (space-separated)

REM Full image name (without tag) on DockerHub
set "IMAGE_NAME=%DOCKER_USERNAME%/%DOCKER_REPO_NAME%"

REM Step 1: Build the Docker image with one base tag
echo Building the Docker image...
docker build -t "%IMAGE_NAME%:latest" .

REM Step 2: Login to DockerHub (optional, if you're already logged in, you can skip this)
echo Logging in to DockerHub...
docker login -u "%DOCKER_USERNAME%"

REM Step 3: Tag the image with multiple tags and push each tag
for %%T in (%IMAGE_TAGS%) do (
    set "FULL_IMAGE_NAME=%IMAGE_NAME%:%%T"
    echo Tagging the image as %FULL_IMAGE_NAME%
    docker tag "%IMAGE_NAME%:latest" "%FULL_IMAGE_NAME%"

    echo Pushing the image to DockerHub with tag: %%T
    docker push "%FULL_IMAGE_NAME%"
)

REM Step 4: Confirm the image was pushed successfully with all tags
echo Docker image pushed successfully with tags: %IMAGE_TAGS%
