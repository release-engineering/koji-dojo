#!/bin/bash

DIR=$(dirname $(realpath $0))

docker build --tag=docker.io/buildchimp/koji-hub $DIR