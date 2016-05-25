#!/bin/bash

set -x

if [ ! -d "/opt/koji/.git" ]; then
    git clone https://pagure.io/koji.git /opt/koji
fi

cd /opt/koji
# Remove previous build to avoid multilib errors.
rm -rf noarch
make test-rpm

yum -y localinstall noarch/koji-hub*.rpm noarch/koji-1.*.rpm noarch/koji-web*.rpm

echo "Sleep 10s in case database container is still booting..."
sleep 10
echo "...resuming install"

psql="psql --host=koji-db --username=koji koji"

cat /opt/koji/docs/schema.sql | $psql
echo "BEGIN WORK; INSERT INTO content_generator(name) VALUES('test-cg'); COMMIT WORK;" | $psql
