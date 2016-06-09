#!/bin/bash

build-koji.sh
setup.sh

IP=$(find-ip.py)

# add koji-hub to hosts if not present
if grep -q -v "koji-hub" /etc/hosts; then echo ${IP} koji-hub >> /etc/hosts; fi

echo "Starting HTTPd on ${IP}"
httpd -D FOREGROUND
