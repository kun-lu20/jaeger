#!/bin/bash

set -exu

make create-baseimg
repo=kunluibm/jaegertest

docker buildx build --push \
    --progress=plain --target release \
    --build-arg base_image=localhost:5000/baseimg:1.0.0-alpine-3.12 \
    --build-arg debug_image=golang:1.15-alpine \
    --platform=linux/arm64,linux/amd64,linux/s390x \
    --file cmd/all-in-one/Dockerfile \
    --tag $repo:latest cmd/all-in-one