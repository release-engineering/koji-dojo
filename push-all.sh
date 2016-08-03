#!/bin/bash

docker login -u buildchimp
for c in docker.io/buildchimp/koji-dojo-hub:dev docker.io/buildchimp/koji-dojo-client:dev docker.io/buildchimp/koji-dojo-builder:dev; do
	echo "Pushing: $c"
	docker push $c
done