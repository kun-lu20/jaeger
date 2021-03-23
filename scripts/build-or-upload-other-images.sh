#!/bin/bash

set -euxf -o pipefail

DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-"jaegertracingbot"}
DOCKERHUB_TOKEN=${DOCKERHUB_TOKEN:-}
QUAY_USERNAME=${QUAY_USERNAME:-"jaegertracing+github_workflows"}
QUAY_TOKEN=${QUAY_TOKEN:-}

# Only push images to dockerhub/quay.io for master branch or for release tags vM.N.P
if [[ "$BRANCH" == "master" || $BRANCH =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "build multiarch images and upload to dockerhub/quay.io, BRANCH=$BRANCH"
  PUSHTAG="type=image, push=true" make docker-images-cassandra-multiarch-nopush
else
  echo 'skip multiarch docker images upload, only allowed for tagged releases or master (latest tag)'
  PUSHTAG="type=image, push=true" make docker-images-cassandra-multiarch-nopush
fi

