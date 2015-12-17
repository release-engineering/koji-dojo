#!/bin/bash

if [ ! -d temp ]; then
	mkdir temp
fi

docker run -d --name=koji-db docker.io/buildchimp/koji-db
docker run -ti --rm --name=koji-hub -v /home/jdcasey/code/docker/koji/hub/temp:/koji-clients --link koji-db:koji-db docker.io/buildchimp/koji-hub
docker stop koji-db && docker rm koji-db
