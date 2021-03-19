#!/bin/bash

set -exu

make create-baseimg
repo=kunluibm/jaegertest

docker buildx build --push --progress=plain \
    --build-arg base_image=localhost/baseimg:1.0.0-alpine-3.12 \
    --build-arg debug_image=localhost/baseimg:1.0.0-alpine-3.12 \
    --platform=linux/arm64,linux/amd64,linux/s390x \
    --file cmd/all-in-one/Dockerfile \
    --tag $repo/all-in-one:latest cmd/all-in-one