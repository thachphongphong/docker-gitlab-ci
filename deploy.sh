#!/bin/bash
set -e
VERSION=$1
CI_REGISTRY_URL = ""
CI_REGISTRY_USER = ""
CI_PROJECT_NAME = ""
CI_REGISTRY_PASSWORD = ""
IMAGE_NAME = $CI_REGISTRY_URL/$CI_REGISTRY_USER/$CI_PROJECT_NAME:$VERSION

echo "START! Deployed new version: $VERSION"

#Pull new image
echo "STEP 1: Pull new version of image"
docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY_URL
docker pull $IMAGE_NAME || true

#Stop current docker container
echo "STEP 2: Check new image is exist"
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" != "" ]]; then
	echo "STEP 3: Deploy new image"
	docker rm -f node-frontend || true
	docker run -p 8080:80 -d --name=$CI_PROJECT_NAME --restart=on-failure $IMAGE_NAME || true
fi

echo "Done! deployed new version: $VERSION"