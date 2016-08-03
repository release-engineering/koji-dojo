#!/bin/bash

DIR=$(dirname $(dirname $(realpath $0)))

set -x
docker build --tag=docker.io/buildchimp/koji-dojo-hub:dev $DIR
