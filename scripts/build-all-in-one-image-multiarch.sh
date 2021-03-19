#!/bin/bash

set -exu

docker buildx create --driver-opt network=host

make create-baseimg-debugimg
repo=kunluibm/jaegertest

docker buildx build --push --progress=plain \
    --build-arg base_image=localhost/baseimg:1.0.0-alpine-3.12 \
    --build-arg debug_image=localhost/debugimg:1.0.0-golang-1.15-alpine \
    --platform=linux/arm64,linux/amd64,linux/s390x \
    --file cmd/all-in-one/Dockerfile \
    --tag $repo:latest cmd/all-in-one