#!/bin/bash

set -x

if [ ! -d /opt/koji ]; then
	# TODO: Enable different versions of Koji instead of the master branch
	git clone https://git.fedorahosted.org/git/koji /opt/koji
fi

cd /opt/koji

make clean
rm -rf noarch koji-*

make test-rpm

yum -y localinstall noarch/koji-hub*.rpm noarch/koji-1.*.rpm

echo "Sleep 10s in case database container is still booting..."
sleep 10
echo "...resuming install"

psql="psql --host=koji-db --username=koji koji"

cat /opt/koji/docs/schema.sql | $psql
echo "BEGIN WORK; INSERT INTO content_generator(name) VALUES('test-cg'); COMMIT WORK;" | $psql
