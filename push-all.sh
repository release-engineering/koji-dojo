#!/bin/bash

docker login -u buildchimp
for c in docker.io/buildchimp/koji-dojo-hub docker.io/buildchimp/koji-dojo-client; do
	dev="${c}:dev"
	echo "Renaming $c with :dev tag"
	docker tag -f $c $dev

	echo "Pushing: $dev"
	docker push $dev
done