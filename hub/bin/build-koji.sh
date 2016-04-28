#!/bin/bash

set -x

if [ ! -d "/opt/koji/.git" ]; then
    git clone https://git.fedorahosted.org/git/koji /opt/koji
fi

cd /opt/koji
make test-rpm

yum -y localinstall noarch/koji-hub*.rpm noarch/koji-1.*.rpm

psql="psql --host=koji-db --username=koji koji"

cat /opt/koji/docs/schema.sql | $psql
