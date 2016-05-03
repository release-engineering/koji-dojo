#!/bin/bash

set -x

cd /mnt
mkdir koji
cd koji
mkdir {packages,repos,work,scratch}
chown apache.apache *

# selinux is disabled
# setsebool -P httpd_can_network_connect_db=1 allow_httpd_anon_write=1
# chcon -R -t public_content_rw_t /mnt/koji/*

IP=$(find-ip.py || echo "kojihub.local")

mkdir -p /etc/pki/koji/{certs,private,confs}

cd /etc/pki/koji

touch index.txt
echo 01 > serial

# CA
openssl genrsa -out private/koji_ca_cert.key 2048

CA_SAN="IP.1:${IP},DNS.1:localhost,DNS.2:${IP}"
conf=confs/ca.cnf

cat ssl.cnf | sed "s/email\:copy/${CA_SAN}/"> $conf

openssl req -config $conf -new -x509 -subj "/C=US/ST=Drunken/L=Bed/O=IT/CN=koji-hub" -days 3650 -key private/koji_ca_cert.key -out koji_ca_cert.crt -extensions v3_ca

cp private/koji_ca_cert.key private/kojihub.key
cp koji_ca_cert.crt certs/kojihub.crt

rm -rf /koji-clients/*

mkuser.sh kojiweb admin
mkuser.sh kojiadmin admin
mkuser.sh testadmin admin
mkuser.sh testuser

chown -R nobody:nobody /opt/koji-clients
chmod -R o+rx /var/log
chmod -R g+rs /var/log
chgrp -R nobody /var/log
