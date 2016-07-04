#!/bin/bash

stop_and_remove_container_and_image() {
    local name=$1
    echo "Stop container koji-$name"
    docker stop koji-$name
    echo "Remove container koji-$name"
    docker rm koji-$name
    echo "Remove container image buildchimp/koji-dojo-$name"
    docker rmi -f buildchimp/koji-dojo-$name
}

stop_and_remove_container_and_image builder