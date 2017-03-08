#!/bin/bash

# Start all koji-dojo containers

docker run -d --name=koji-db \
    -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' \
    postgres:9.4

# start koji-hub container attached (allows to inspect startup messages)
# docker run -ti --name=koji-hub -v /opt/koji-files:/mnt/koji -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients --link koji-db:koji-db docker.io/buildchimp/koji-dojo-hub

docker run -d --name=koji-hub \
    -v /opt/koji-files:/mnt/koji -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients \
    --link koji-db:koji-db \
    docker.io/buildchimp/koji-dojo-hub:dev


# run koji-builder on foreground (by default)
koji_builder_run_mode='-ti'

# if there's '-d' option, run koji-builder on background
test "$#" -gt 0 -a "$1" = '-d' && koji_builder_run_mode='-d'

docker run $koji_builder_run_mode --name=koji-builder --privileged=true \
    -v /opt/koji-files:/mnt/koji -v /opt/koji:/opt/koji \
    --link koji-db --link koji-hub \
    docker.io/buildchimp/koji-dojo-builder:dev
