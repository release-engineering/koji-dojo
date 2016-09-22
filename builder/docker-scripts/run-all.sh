#!/bin/bash

docker run -d --name=koji-db -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' postgres:9.4


# to start attached (allows to inspect startup messages)
# docker run -ti --name=koji-hub -v /opt/koji-files:/mnt/koji -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients --link koji-db:koji-db docker.io/buildchimp/koji-dojo-hub
# to start in background
docker run -d --name=koji-hub -v /opt/koji-files:/mnt/koji -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients --link koji-db:koji-db docker.io/buildchimp/koji-dojo-hub


$(dirname $(realpath $0))/run.sh