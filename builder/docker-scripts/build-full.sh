#!/bin/bash

HUB_DIR=$(dirname $(dirname $(dirname $(realpath $0))))/hub
$HUB_DIR/docker-scripts/build.sh

DIR=$(dirname $(dirname $(realpath $0)))

docker build --tag=docker.io/buildchimp/koji-dojo-builder $DIR