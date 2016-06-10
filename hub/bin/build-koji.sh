#!/bin/bash

set -x

if [ ! -d "/opt/koji/.git" ]; then
    git clone https://pagure.io/koji.git /opt/koji
fi

# install the latest version of python-coverage module
wget https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py
wget https://pypi.python.org/packages/2d/10/6136c8e10644c16906edf4d9f7c782c0f2e7ed47ff2f41f067384e432088/coverage-4.1.tar.gz#md5=80e63edaf49f689d304898fafc1007a5
easy_install coverage-4.1.tar.gz
rm -f coverage-4.1.tar.gz

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
