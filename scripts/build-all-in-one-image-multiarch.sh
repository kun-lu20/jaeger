#!/bin/bash

set -exu

VERSION="1.0.0"
ROOT_IMAGE="alpine:3.12"
CERT_IMAGE="alpine:3.12"
GOLANG_IMAGE="golang:1.15-alpine"

BASE_IMAGE="localhost:5000/baseimg:$VERSION-$(echo $ROOT_IMAGE | tr : -)"

PLATFORMS="linux/amd64,linux/arm64,linux/s390x,linux/ppc64le"

docker buildx build -t $BASE_IMAGE --push \
		--build-arg root_image=$ROOT_IMAGE \
		--build-arg cert_image=$CERT_IMAGE \
		--platform=$PLATFORMS \
		docker/base
        
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-"jaegertracingbot"}
DOCKERHUB_TOKEN=${DOCKERHUB_TOKEN:-}
QUAY_USERNAME=${QUAY_USERNAME:-"jaegertracing+github_workflows"}
QUAY_TOKEN=${QUAY_TOKEN:-}

###############Compute the tag
BASE_BUILD_IMAGE=${BASE_BUILD_IMAGE:-"kunlu20/jaeger-all-in-one"}

## if we are on a release tag, let's extract the version number
## the other possible value, currently, is 'master' (or another branch name)
if [[ $BRANCH == v* ]]; then
    COMPONENT_VERSION=$(echo ${BRANCH} | grep -Po "([\d\.]+)")
    MAJOR_MINOR=$(echo ${COMPONENT_VERSION} | awk -F. '{print $1"."$2}')
else
    COMPONENT_VERSION="latest"
    MAJOR_MINOR=""
fi

# for docker.io
BUILD_IMAGE=${BUILD_IMAGE:-"${BASE_BUILD_IMAGE}:${COMPONENT_VERSION}"}
IMAGE_TAGS="--tag docker.io/${BUILD_IMAGE}"

if [ "${MAJOR_MINOR}x" != "x" ]; then
    MAJOR_MINOR_IMAGE="${BASE_BUILD_IMAGE}:${MAJOR_MINOR}"
    IMAGE_TAGS="${IMAGE_TAGS} --tag docker.io/${MAJOR_MINOR_IMAGE}"
fi

## for quay.io
IMAGE_TAGS="${IMAGE_TAGS} --tag quay.io/${BUILD_IMAGE}"

if [ "${MAJOR_MINOR}x" != "x" ]; then
    IMAGE_TAGS="${IMAGE_TAGS} --tag quay.io/${MAJOR_MINOR_IMAGE}"
fi
################################

# Only push images to dockerhub/quay.io for master branch or for release tags vM.N.P
if [[ "$BRANCH" == "master" || $BRANCH =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "build multiarch images and upload to dockerhub/quay.io, BRANCH=$BRANCH"

  echo "Performing a 'docker login' for DockerHub"
  echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" docker.io --password-stdin

  echo "Performing a 'docker login' for Quay"
  echo "${QUAY_TOKEN}" | docker login -u "${QUAY_USERNAME}" quay.io --password-stdin

  docker buildx build --output "type=image, push=true" \
    --progress=plain --target release \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg debug_image=$GOLANG_IMAGE \
    --platform=$PLATFORMS \
    --file cmd/all-in-one/Dockerfile \
    ${IMAGE_TAGS} \
    cmd/all-in-one
else
  echo 'skip multiarch docker images upload, only allowed for tagged releases or master (latest tag)'
  
  docker buildx build --output "type=image, push=false" \
    --progress=plain --target release \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg debug_image=$GOLANG_IMAGE \
    --platform=$PLATFORMS \
    --file cmd/all-in-one/Dockerfile \
    ${IMAGE_TAGS} \
    cmd/all-in-one
fi