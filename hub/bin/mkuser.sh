#!/bin/bash

set -x

psql="psql --host=koji-db --username=koji koji"

IP=$(find-ip.py || "koji-hub.local")

user=$1
kind=$2

if [ "x$user" == "x" ]; then
	echo "Usage: $0 <username> [admin|user|builder]"
fi

if [ "x$kind" == "xbuilder" ]; then
	echo "Add builder $user"
	echo "INSERT INTO users (name, status, usertype) VALUES ('${user}', 0, 1);" | $psql
	echo "INSERT INTO host (id, user_id, name, arches) SELECT nextval('host_id_seq'), users.id, '${user}', 'x86_64' FROM users WHERE name = '${user}';" | $psql
	echo "INSERT INTO host_channels (host_id, channel_id) SELECT (SELECT id FROM host WHERE name = '${user}') as host_id, channels.id FROM channels WHERE name in ('default', 'createrepo', 'maven');" | $psql
else
	echo "Add user ${user}"
	echo "INSERT INTO users (name, status, usertype) VALUES ('${user}', 0, 0);" | $psql
fi

if [ "x$kind" == "xadmin" ]; then
	uid=$(echo "select id from users where name = '${user}'" | $psql | tail -3 | head -1)
	echo "Assigning admin privileges to: ${user} with uid: ${uid}"
	echo "INSERT INTO user_perms (user_id, perm_id, creator_id) VALUES (${uid}, 1, ${uid});" | $psql
fi

cd /etc/pki/koji

#if you change your certificate authority name to something else you will need to change the caname value to reflect the change.
caname="koji"

# user is equal to parameter one or the first argument when you actually run the script
user=$1
password="mypassword"
conf=confs/${user}-ssl.cnf

openssl genrsa -out private/${user}.key 2048
cp ssl.cnf $conf

openssl req -config $conf -new -nodes -out certs/${user}.csr -key private/${user}.key \
            -subj "/C=US/ST=Drunken/L=Bed/O=IT/CN=${user}/emailAddress=${user}@kojihub.local"

openssl ca -config $conf -batch -keyfile private/${caname}_ca_cert.key -cert ${caname}_ca_cert.crt \
		   -out certs/${user}-crtonly.crt -outdir certs -infiles certs/${user}.csr

openssl pkcs12 -export -inkey private/${user}.key -passout "pass:${password}" -in certs/${user}-crtonly.crt -certfile ${caname}_ca_cert.crt -CAfile ${caname}_ca_cert.crt -chain -clcerts \
			   -out certs/${user}_browser_cert.p12

openssl pkcs12 -clcerts -passin "pass:${password}" -passout "pass:${password}" -in certs/${user}_browser_cert.p12 -inkey private/${user}.key -out certs/${user}.pem

cat certs/${user}-crtonly.crt private/${user}.key > certs/${user}.crt

client=/opt/koji-clients/${user}

rm -rf $client
mkdir -p $client
cp /etc/pki/koji/certs/${user}.crt $client/client.crt   # NOTE: It is IMPORTANT you use the aggregated form
cp /etc/pki/koji/certs/${user}.pem $client/client.pem
cp /etc/pki/koji/certs/${user}_browser_cert.p12 $client/client_browser_cert.p12
cp /etc/pki/koji/koji_ca_cert.crt $client/clientca.crt
cp /etc/pki/koji/koji_ca_cert.crt $client/serverca.crt

cat <<EOF > $client/config
[koji]
server = https://${IP}/kojihub
authtype = ssl
cert = ${client}/client.crt
ca = ${client}/clientca.crt
serverca = ${client}/serverca.crt
EOF

cat <<EOF > $client/config.json
{
	"url": "https://${IP}/kojihub",
	"crt-url": "https://${IP}/koji-clients/${user}/client.crt",
	"pem-url": "https://${IP}/koji-clients/${user}/client.pem",
	"ca-url": "https://${IP}/koji-clients/${user}/clientca.crt",
	"serverca-url": "https://${IP}/koji-clients/${user}/serverca.crt",
	"crt": "${client}/client.crt",
	"pem": "${client}/client.pem",
	"ca": "${client}/clientca.crt",
	"serverca": "${client}/serverca.crt"
}
EOF

chown -R nobody:nobody ${client}
