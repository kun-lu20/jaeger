#!/bin/bash

set -euxf -o pipefail

DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-"jaegertracingbot"}
DOCKERHUB_TOKEN=${DOCKERHUB_TOKEN:-}
QUAY_USERNAME=${QUAY_USERNAME:-"jaegertracing+github_workflows"}
QUAY_TOKEN=${QUAY_TOKEN:-}

###############Compute the tag
BASE_BUILD_IMAGE=${BASE_BUILD_IMAGE:-"kunlu20/jaeger-JAGERCOMP"}

## if we are on a release tag, let's extract the version number
## the other possible value, currently, is 'master' (or another branch name)
if [[ $BRANCH == v* ]]; then
    COMPONENT_VERSION=$(echo ${BRANCH} | grep -Po "([\d\.]+)")
    MAJOR_MINOR=$(echo ${COMPONENT_VERSION} | awk -F. '{print $1"."$2}')
else
    COMPONENT_VERSION="latest"
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

if [ "${MAJOR_MINOR_IMAGE}x" != "x" ]; then
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

  IMAGE_TAGS="${IMAGE_TAGS}" PUSHTAG="type=image, push=true" make docker-images-cassandra-multiarch-nopush
else
  echo 'skip multiarch docker images upload, only allowed for tagged releases or master (latest tag)'
  IMAGE_TAGS="${IMAGE_TAGS}" PUSHTAG="type=image, push=false" make docker-images-cassandra-multiarch-nopush
fi

