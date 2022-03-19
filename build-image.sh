#!/bin/bash

# Check if we actually need to build the current version.
cd veloren
source .build_env

for tag in $(curl -s https://registry.hub.docker.com/v1/repositories/$DOCKERHUB_USERNAME/$IMAGE_NAME/tags | jq -r ".[].name"); do
    if [[ "$tag" == "$VELOREN_VERSION" ]]; then
        echo "Release $tag has already been built."
        exit
    fi
done

# If we do, make sure the submodule is checked out to the tag to build
git checkout $VELOREN_VERSION
cd ..

# Set up BuildKit
docker buildx create --driver docker-container --use
docker buildx inspect --bootstrap
update-binfmts --enable

# Always build the server to ensure builds still work, even if we don't keep the artifacts
docker buildx build --build-arg VELOREN_VERSION=$VELOREN_VERSION --build-arg BUILD_ARGS=$VELOREN_BUILD_ARGS \
--output type=local,dest=./artifacts \
--platforms $PLATFORMS \
--target exporter

# Only when we're looking at a push to main do we actually want to publish artifacts and images
if [ ${CI_COMMIT_SOURCE_BRANCH} == 'main' ]; then

    # Log in to registries
    docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN
    docker login -u $GITHUB_USERNAME -p $GITHUB_TOKEN ghcr.io

    # Build again - this should be quick as BuildKit will have cached the actual build stage from before
    docker buildx build --build-arg VELOREN_VERSION=$VELOREN_VERSION --build-arg BUILD_ARGS=$VELOREN_BUILD_ARGS \
        --output type=local,dest=./artifacts \
        --platforms $PLATFORMS \
        --target server \
        --push \
        -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$BUILDTYPE-$VELOREN_VERSION \
        -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$VELOREN_IMAGE_TAG \
        -t ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$BUILDTYPE-$VELOREN_VERSION \
        -t ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$VELOREN_IMAGE_TAG

    # TODO: publish artifacts to github release
fi
