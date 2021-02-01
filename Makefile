SHELL=/bin/bash -o pipefail

SQLITE_VERSION=master
SQLITE_TAG=nightly

.PHONY: bootstrap reset build remove-local-images

bootstrap:
	docker build                       \
		--target builder               \
		--tag localhost/sqlite:builder \
		- < ./Dockerfile

reset:
	docker image rm localhost/sqlite:repository

sqlite-releases:
	( cd ./sqlite ; git tag | grep -E '^version-.*$$' > ../sqlite-releases )

# cat <( tar --create --file - ./Dockerfile ) <( cd ./sqlite/ ; git archive --format tar master )
build: bootstrap
	docker build                                          \
		--target sqlite                                     \
		--build-arg SQLITE_VERSION=$(SQLITE_VERSION)        \
		--tag andresteenveld/sqlite:$(SQLITE_TAG)           \
		--cache-from localhost/sqlite:builder               \
		--rm .                                              \
	| tee >( sed -e 's/\x1b\[.\{1,5\}m//g' > $(SQLITE_VERSION).build.log ) \
	| sed -e 's/^/[ $(SQLITE_TAG) ] /';

	docker run --rm --tty andresteenveld/sqlite:$(SQLITE_TAG) --version         \
		&& rm ./$(SQLITE_VERSION).build.log                                     \
		|| mv ./$(SQLITE_VERSION).build.log ./$(SQLITE_VERSION).build-failed.log;

	docker image prune

remove-local-images:
	docker rmi --force $$(docker image ls --quiet --filter=reference=andresteenveld/sqlite)