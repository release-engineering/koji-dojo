#!/bin/bash

set -x

# TODO: Enable different versions of Koji instead of the master branch
git clone https://git.fedorahosted.org/git/koji /opt/koji

cd /opt/koji
make test-rpm

yum -y localinstall noarch/koji-hub*.rpm noarch/koji-1.*.rpm

psql="psql --host=koji-db --username=koji koji"

cat /opt/koji/docs/schema.sql | $psql
