#!/bin/bash

build-koji.sh
setup.sh

IP=$(find-ip.py)

# add koji-hub to hosts if not present
if grep -q -v "koji-hub" /etc/hosts; then echo ${IP} koji-hub >> /etc/hosts; fi

echo "Starting ssh on ${IP} (use ssh root@${IP} with password mypassword"
#/etc/init.d/sshd start
/usr/sbin/sshd 
echo "You can connect directly by running"
echo "      docker exec -ti koji-hub /bin/bash"
echo "Starting HTTPd on ${IP}"
httpd -D FOREGROUND
