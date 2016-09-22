#!/bin/bash

# It's important to run the container with privileged rights because mock needs the "unshare" system call to create a new mountpoint inside the process.
# Withour this you will get this error:
#
# ERROR: Namespace unshare failed.
#
# If the '--cap-add=SYS_ADMIN' is not working for you, you can run the container with the privilaged parameter. Replace '--cap-add=SYS_ADMIN' with '--privileged=true'.
# Reference: https://github.com/mmornati/docker-mock-rpmbuilder
#
#docker run --cap-add=SYS_ADMIN -ti --name=koji-builder -v /opt/koji-files:/mnt/koji --link koji-db --link koji-hub docker.io/buildchimp/koji-dojo-builder
docker run --privileged=true -ti --name=koji-builder -v /opt/koji-files:/mnt/koji --link koji-db --link koji-hub docker.io/buildchimp/koji-dojo-builder
