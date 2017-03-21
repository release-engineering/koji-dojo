# A set of Makefile targets that is to be run inside Vagrant quest VM

.PHONY: clean sources rpm-scratch-build

# Remove koji-dojo Docker containers and images; cleanup build directories
clean:
	docker rm -f koji-hub koji-db koji-builder
	printf "Attempted to drop existing containers, ignoring the missing ones.\nDone\n"
	docker images | grep '^docker.io/buildchimp/koji-dojo-' \
	| awk '{ print $$3 }' | xargs docker rmi
	rm -rf /opt/koji-files/[prsw]*

# Apply a critical patch that isn't yet in the master branch
sources:
	patch -f -d /usr/bin < ./patches/koji-pr-307.patch ; echo;
	printf "Attempted to patch koji, skipping possible 'Already patched' errors\nDone\n"

# Congigure Koji tags and repos then run a sample scratch build task
rpm-scratch-build: scratchbuild ?= ./buildroot/fedora-25-noarch
rpm-scratch-build:
	$(scratchbuild)
