VERSION := 1.0.0
ROOT_IMAGE ?= alpine:3.12
CERT_IMAGE := alpine:3.12
GOLANG_IMAGE := golang:1.15-alpine

BASE_IMAGE := localhost:5000/baseimg:$(VERSION)-$(shell echo $(ROOT_IMAGE) | tr : -)
DEBUG_IMAGE := localhost/debugimg:$(VERSION)-$(shell echo $(GOLANG_IMAGE) | tr : -)

create-baseimg-debugimg: create-baseimg create-debugimg

create-baseimg:
	docker buildx build -t $(BASE_IMAGE) --push \
		--build-arg root_image=$(ROOT_IMAGE) \
		--build-arg cert_image=$(CERT_IMAGE) \
		--platform=linux/arm64,linux/amd64,linux/s390x \
		docker/base

create-debugimg:
	docker buildx build -t $(DEBUG_IMAGE) --push \
		--build-arg golang_image=$(GOLANG_IMAGE) \
		--platform=linux/arm64,linux/amd64,linux/s390x \
		docker/debug
