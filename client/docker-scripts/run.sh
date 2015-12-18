#!/bin/bash

docker run -d --name=koji-db -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' postgres:9.4
docker run -d --name=koji-hub --link koji-db:koji-db docker.io/buildchimp/koji-dojo-hub

while true; do
	echo "Waiting for koji-hub to start..."
#	tail=$(docker logs --tail=100 2>&1)
	hubstart=$(docker logs --tail=5 koji-hub | grep "Starting HTTPd")
	echo $hubstart
	if [ "x$hubstart" != "x" ]; then
		echo "koji-hub started:"
	    break
	fi
	sleep 5
done

docker run -ti --rm --name=koji-client --volumes-from koji-hub docker.io/buildchimp/koji-client-dojo

docker stop koji-hub koji-db
docker rm koji-hub koji-db
