CURRENT_VERSION := $(shell git rev-parse HEAD)
DOCKER_LATEST_TAG_NAME := jelrikvanhal/build-environment:latest
DOCKER_PINNED_TAG_NAME := jelrikvanhal/build-environment:$(CURRENT_VERSION)
UPDATE_LATEST_TAG ?= 0

.PHONY: build
build: .built

.PHONY: test
test: .tested

.PHONY: publish
publish: .published

.built: Dockerfile Makefile
	docker build . --file Dockerfile --tag $(DOCKER_PINNED_TAG_NAME)
	touch $@

.tested: .built
	docker run --rm $(DOCKER_PINNED_TAG_NAME) sh -c '\
		docker -v | grep 'Docker version 20.' && \
		docker-compose -v | grep 'docker-compose version 1.' && \
		git --version | grep 'git version' && \
		make -v | grep 'GNU Make'\
	'
	touch $@

.published: .tested
	docker push $(DOCKER_PINNED_TAG_NAME)
ifeq ($(UPDATE_LATEST_TAG),1)
	docker tag $(DOCKER_PINNED_TAG_NAME) $(DOCKER_LATEST_TAG_NAME)
	docker push $(DOCKER_LATEST_TAG_NAME)
endif
	touch $@
