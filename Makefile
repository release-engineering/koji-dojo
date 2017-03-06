## Shortcuts for common koji-dojo operations.

KOJI = koji -c /opt/koji-clients/kojiadmin/config

.PHONY: run clean sources rpm-scratch-build lint

## Install and configure Docker
init:
	test "$$USER" = 'root'
	dnf install -y docker vim-enhanced tree
	sudo systemctl enable docker
	sudo systemctl start docker

## Install vagrant
init-vagrant:
	dnf install vagrant vagrant-libvirt

## Build koji-dojo containers
build:
	sed -i 's|^allowed_scms.*|allowed_scms=pkgs.devel.redhat.com:/*:no:rhpkg,sources \
	   src.fedoraproject.org:/*:no pkgs.fedoraproject.org:/*:no:fedpkg,sources|' \
	   builder/bin/entrypoint.sh
	cd builder/docker-scripts && ./build-all.sh

## Start koji containers. koji-builder container with kojid will run interactively
run:
	sudo docker rm -f koji-hub koji-builder koji-db;\
		printf "Attempted to drop existing containers, ignoring the missing ones.\nDone\n";
	rm -rf /opt/koji-{clients,files}/*
	cd builder/docker-scripts && ./run-all.sh -d

## Remove koji-dojo Docker containers and images; cleanup build directories
clean:
	docker rm -f koji-hub koji-db koji-builder ;\
	docker images | grep '^docker.io/buildchimp/koji-dojo-' | awk '{ print $$3 }' | xargs docker rmi ;\
	rm -rf /opt/koji-files/[prsw]*

## TODO Use fedpkg sources (?)
sources:
	wget http://fedora.mirrors.ovh.net/linux/releases/25/Everything/source/tree/Packages/k/koji-1.10.1-13.fc25.src.rpm
	patch -f -d /usr/bin < ./patches/koji-pr-307.patch ; \
		printf "Attempted to patch koji, skipping possible 'Already patched' errors\nDone\n"


## Run a demo build task that builds koji RPM packages for Fedora 25
rpm-scratch-build: sources
rpm-scratch-build:
	$(KOJI) hello
	$(KOJI) add-tag destination-tag --include-all --arches="noarch"
	$(KOJI) add-tag build-tag --include-all --arches="x86_64"
	$(KOJI) add-external-repo -t build-tag build-external-repo https://kojipkgs.fedoraproject.org/repos/f25-build/latest/\$$arch/
	koji show-groups --comps f25-build | $(KOJI) import-comps /dev/stdin build-tag
	touch /tmp/0_o
	$(KOJI) regen-repo build-tag
	$(KOJI) add-target build-target build-tag destination-tag
	$(KOJI) build --scratch build-target koji-1.10.1-13.fc25.src.rpm
	find /opt/koji-files/scratch/ -newer /tmp/0_o -name \*rpm
