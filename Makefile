SHELL=/bin/bash -o pipefail

SQLITE_VERSION=master
SQLITE_TAG=nightly

.PHONY: bootstrap reset build remove-local-images

bootstrap:
	docker build --target repository --tag localhost/sqlite:repository - < ./Dockerfile

reset:
	docker image rm localhost/sqlite:repository

sqlite-releases:
	docker run --rm --workdir /usr/local/src/sqlite localhost/sqlite:repository git tag \
		| grep -E '^version-.*$$' > ./sqlite-releases

build:
	docker build --rm                                                          \
		--cache-from localhost/sqlite:repository                               \
		--target sqlite                                                        \
		--build-arg SQLITE_VERSION=$(SQLITE_VERSION)                           \
		--tag andresteenveld/sqlite:$(SQLITE_TAG)                              \
		- < ./Dockerfile                                                       \
		| tee >( sed -e 's/\x1b\[.\{1,5\}m//g' > $(SQLITE_VERSION).build.log ) \
		| sed -e 's/^/[ $(SQLITE_TAG) ] /';

	docker run --rm --tty andresteenveld/sqlite:$(SQLITE_TAG) sqlite3 --version \
		&& rm ./$(SQLITE_VERSION).build.log                                     \
		|| mv ./$(SQLITE_VERSION).build.log ./$(SQLITE_VERSION).build-failed.log;

	docker image prune --force

remove-local-images:
	docker rmi --force $$(docker image ls --quiet --filter=reference=andresteenveld/sqlite)