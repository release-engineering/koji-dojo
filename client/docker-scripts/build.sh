#!/bin/bash

DIR=$(dirname $(dirname $(realpath $0)))

docker build --tag=docker.io/buildchimp/koji-client-dojo $DIR