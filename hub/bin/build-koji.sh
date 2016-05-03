#!/bin/bash

set -x

if [ ! -d "/opt/koji/.git" ]; then
    git clone https://git.fedorahosted.org/git/koji /opt/koji
fi

cd /opt/koji
# Remove previous build to avoid multilib errors.
rm -rf noarch
make test-rpm

yum -y localinstall noarch/koji-hub*.rpm noarch/koji-1.*.rpm noarch/koji-web*.rpm

psql="psql --host=koji-db --username=koji koji"

cat /opt/koji/docs/schema.sql | $psql
