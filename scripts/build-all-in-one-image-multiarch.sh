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
        
repo=kunlu20/jaeger-all-in-one

docker buildx build --push \
    --progress=plain --target release \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg debug_image=$GOLANG_IMAGE \
    --platform=$PLATFORMS \
    --file cmd/all-in-one/Dockerfile \
    --tag $repo:latest cmd/all-in-one