#!/bin/bash

wait_for_koji_hub_to_start() {
    while true; do
        echo "Waiting for koji-hub to start..."
        hubstart=$(curl -X GET http://koji-hub/)
        #echo $hubstart
        if [ "x$hubstart" != "x" ]; then
            echo "koji-hub started:"
            break
        fi
        sleep 5
    done
}

install_builder() {
    if [ -d /opt/koji/noarch ]; then
        echo "Installing from /opt/koji/noarch"
        yum -y localinstall /opt/koji/noarch/koji-1*.rpm
        yum -y localinstall /opt/koji/noarch/koji-builder*.rpm
    else
        echo "No koji RPM to install! Installing from EPEL"
        yum -y install epel-release
        yum -y install koji-builder
    fi
}

configure_builder() {
    echo "Configure builder to connect to koji-hub"

    wget http://koji-hub/clients/kojibuilder/client.crt -O /etc/kojid/kojibuilder.crt
    wget http://koji-hub/clients/kojibuilder/clientca.crt -O /etc/kojid/koji_client_ca_cert.crt
    wget http://koji-hub/clients/kojibuilder/serverca.crt -O /etc/kojid/koji_server_ca_cert.crt


# delete line starting with allowed_scms=
cp /etc/kojid/kojid.conf /etc/kojid/kojid.conf.example
sed -i.bak '/topurl=/d' /etc/kojid/kojid.conf
sed -i.bak '/server=/d' /etc/kojid/kojid.conf
sed -i.bak '/allowed_scms=/d' /etc/kojid/kojid.conf

    cat <<EOF >> /etc/kojid/kojid.conf


allowed_scms=myrepo.com:/*:no github.com:/*:no

; The URL for the xmlrpc server
server=http://koji-hub/kojihub

; the username has to be the same as what you used with add-host
; in this example follow as below
user = kojibuilder

; The URL for the file access
topurl=http://koji-hub/kojifiles

; The directory root for temporary storage
workdir=/tmp/koji

; The directory root where work data can be found from the koji hub
topdir=/mnt/koji

;client certificate
; This should reference the builder certificate we created on the kojihub CA, for kojibuilder
; ALSO NOTE: This is the PEM file, NOT the crt
cert = /etc/kojid/kojibuilder.crt

;certificate of the CA that issued the client certificate
ca = /etc/kojid/koji_client_ca_cert.crt

;certificate of the CA that issued the HTTP server certificate
serverca = /etc/kojid/koji_server_ca_cert.crt

EOF
    diff /etc/kojid/kojid.conf.example /etc/kojid/kojid.conf
}


start_ssh() {
    local RUN_IN_FOREGROUND=$1
    echo "You can connect directly by running"
    echo "      docker exec -ti koji-hub /bin/bash"
    echo "Starting ssh on ${IP} (use ssh root@${IP} with password mypassword"
    if [ "$RUN_IN_FOREGROUND" == "RUN_IN_FOREGROUND" ]; then
        ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
        ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
        /usr/sbin/sshd -D
    else
        /etc/init.d/sshd start
    fi
}

start_builder() {
    local RUN_IN_FOREGROUND=$1
    echo "Starting koji builder on ${IP}"
    if [ "$RUN_IN_FOREGROUND" == "RUN_IN_FOREGROUND" ]; then
        /usr/sbin/kojid -d -v -f --force-lock
    else
        /etc/init.d/kojid start
    fi
}

set -x
IP=$(find-ip.py)

wait_for_koji_hub_to_start
install_builder
configure_builder
start_ssh
start_builder "RUN_IN_FOREGROUND"
