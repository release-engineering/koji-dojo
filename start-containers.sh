#!/bin/sh

# Install and configure Docker on Vagrant guest VM.
# Start Koji-Dojo containers.

dnf -y install make docker koji wget patch tree rpm-build
systemctl enable docker
systemctl start docker

# Allow Koji to use Fedora repos
sed -i 's|^allowed_scms.*|allowed_scms=src.fedoraproject.org:/*:no  \
    pkgs.fedoraproject.org:/*:no:fedpkg,sources|' \
    /vagrant/builder/bin/entrypoint.sh

mkdir -p /opt/koji-files
chmod 777 -R /opt/koji-files

# Build and start koji-dojo containers
cd /vagrant/builder/docker-scripts
./build-all.sh
./run-all.sh -d
echo "Koji Docker containers are started"
kojiconfig=/opt/koji-clients/kojiadmin/config 
test -f $kojiconfig || \
    echo Waiting for koji-hub to initialize configuration files... ;\
    until test -f $kojiconfig ; do printf . ; sleep 2 ; done
sleep 4; echo .. done
