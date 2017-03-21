# Shortcuts for common koji-dojo operations
# See ./vagrant-guest.mk for the targets that run inside Vagrant guest VM

MAKEFLAGS = -s
DBDUMP_TEMPLATE = /tmp/koji-dojo-db-XXX.pgdump

.PHONY: demo-build init-vagrant dbshell dbdump

demo-build:
	vagrant ssh -c " \
		sudo make -C /vagrant -f /vagrant/vagrant-guest.mk sources rpm-scratch-build"

# Install vagrant
init-vagrant:
	dnf install vagrant vagrant-libvirt

# Open PostgreSQL shell
dbshell:
	vagrant ssh -c 'sudo docker exec -it koji-db psql koji -U koji'

# login to a specified Docker container
enter: container ?= koji-hub
enter:
	echo "Logging in to '$(container)'"
	vagrant ssh -c 'sudo docker exec -it $(container) /bin/bash'

# Dump the database to a local file
dbdump:
	dumpfile=`mktemp $(DBDUMP_TEMPLATE)` ;\
	vagrant ssh -c 'sudo docker exec -it koji-db pg_dump koji -U koji' \
		> $$dumpfile ;\
	echo $$dumpfile
