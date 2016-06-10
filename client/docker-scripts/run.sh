#!/bin/bash

docker run -d --name=koji-db -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' postgres:9.4

docker run -d --name=koji-hub -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients --link koji-db docker.io/buildchimp/koji-dojo-hub

docker run -ti --rm --name=koji-client --volumes-from koji-hub --link koji-hub docker.io/buildchimp/koji-dojo-client

docker stop koji-hub koji-db
docker rm koji-hub koji-db
