#!/bin/bash

if [ ! -d /tmp/koji-clients ]; then
	mkdir -p /tmp/koji-clients
fi

if [ ! -d /tmp/koji ]; then
	mkdir -p /tmp/koji
fi

chcon -Rt svirt_sandbox_file_t /tmp/koji-clients
chcon -Rt svirt_sandbox_file_t /tmp/koji

docker run -d --name=koji-db -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' postgres:9.4

docker run -ti --rm --name=koji-hub -v /tmp/koji:/opt/koji -v /tmp/koji-clients:/opt/koji-clients --link koji-db:koji-db docker.io/buildchimp/koji-dojo-hub:dev

docker stop koji-db && docker rm koji-db
