# Koji Dojo

Koji dojo is a suite of Docker images that are designed to enable automated testing for applications that need to integrate with Koji.

## Images

Currently, there are three images:

* `hub/` - This is a simplistic build of the Koji hub service, configured to enable SSL authentication. It is based on the CentOS 6 Docker image
* `client/` - This is a minimal CentOS 6 image that mounts volumes from the hub container and installs the Koji client RPM from it. It will also link and configure scripts for each of the users generated in the hub setup.
* `builder/` - This is a simplistic build of the Koji builder service connected to hub. It is based on the CentOS 6 Docker image

## Docker Maintenance Scripts

* `build-all.sh` - Runs `docker build ...` for building the images in this repository
* `*/docker-scripts/build.sh` - Runs `docker build ...` for just the given image (hub, client, etc.)
* `*/docker-scripts/run.sh` - Starts any containers needed to support the given image, then starts a new container for the given image itself, monitoring system in/out. When you use CTL-C to escape the container, the supporting containers are stopped and removed as well.
* `*/docker-scripts/start.sh` - Starts supporting container and a new container for the given image. Each container is started in daemon mode.
* `*/docker-scripts/stop.sh` - Stops and removes the container for the given image and any supporting containers.

## Docker Compose

* Build all images: `docker-compose build`
* Start all containers: `docker-compose up` (Use -d for detached mode)
* Stop and remove all containers: `docker-compose down`

* koji-hub's IP address must be added to local /etc/hosts such as:
    `172.17.0.3   koji-hub`

## Hub Image Notes

When the hub initializes, it checks out Koji sources from Git, builds them, and installs the koji-hub* RPMs. The sources are cloned into `/opt/koji`, which is exposed as a Docker volume. This enables the `client` image to install the client RPM that was built in conjunction with the hub RPMs.

The Koji hub image generates three users on initialization:

* kojiadmin
* testadmin
* testuser

The Koji hub image generates one host on initialization:

* kojibuilder

The PKCS#12 SSL certificates for these each use the password 'mypassword'. The certificates, CA cert files, and a basic Koji configuration file is stored for each user under `/opt/koji-clients/<user>`. Along with these, a basic JSON file is stored for each user that gives the URL and SSL file references in a way that's easy to use for non-Koji clients. The `/opt/koji-clients` directory is exposed as a volume in the Docker container, so it can be mounted in other containers via the `--volumes-from` Docker run option.

User accounts and source build aside, this hub image also exposes the `/opt/koji-clients` and `/var/log` directories via HTTP. This enables an application's tests to use simple HTTP to retrieve the generated SSL certificates, and to download the relevant log files for the webserver and Koji hub in case a test fails.

You can also use the hub container from your localhost by using a manual volume mount from the localhost directory structure into the hub container:

```
docker run -d --name=koji=hub -v /opt/koji-clients:/opt/koji-clients docker.io/buildchimp/koji-hub
```

Now, if you have the Koji client RPM installed locally, you can start using the hub container by simply using one of the generated configs:

```
koji -c /opt/koji-clients/testuser/config hello
```

```
koji -c /opt/koji-clients/testuser/config list-tags
```


## Client Image Notes

The client container mounts all exposed volumes from the hub. During initialization, it installs the Koji client RPM in `/opt/koji/noarch` (built by the hub during its own initialization), then uses the SSL configurations under `/opt/koji-clients` to generate `/root/.koji/config` with headings like `koji-testuser`. Next it symlinks `/usr/local/koji` to corresponding script names (eg. `koji-testuser`) under `/root/bin`.

Finally, the client container sets up SSH host keys and starts the SSHd daemon. It prints the IP address and port for this SSHd instance to the docker log.

## Web Browser Certificates

Certificates for the various accounts created during hub container
initialization can be found at `/opt/koji-clients`.

Install the corresponding cert in your browser to enable logins.
In Chrome, for example, this can be done via UI or via the command line
by using pk12util:

`pk12util -d sql:$HOME/.pki/nssdb -i /opt/koji-clients/testuser/client_browser_cert.p12 -W mypassword`

## Builder notes

To use builder please use builder/docker-scripts/build-all.sh to build hub image instead of hub//docker-scripts/build.sh (please see comments inside the script for explanation)

To start koji-db, koji-hub and koji-builder please use builder/docker-scripts/run.sh

Example of builder bootstrap:

~~~~
# build builder
./builder/docker-scripts/build.sh

# start builder (includes start of koji-db and koji-hub)
# please note koji hub will be started using different options tham specified in ./hub/docker-scripts/run.sh
# because additional volume /opt/koji-files is mapped to be shared with builder
./builder/docker-scripts/run.sh

# create alias for to allow use local koji installation
# optionally you can use koji-client container
alias kojitest="koji -c /opt/koji-clients/kojiadmin/config"

# verify koji is running
kojitest hello

# show cert info
pk12util -d sql:$HOME/.pki/nssdb -l /opt/koji-clients/kojiadmin/client_browser_cert.p12 -W mypassword
# show certificates
certutil -d sql:$HOME/.pki/nssdb -L

# delete
certutil -d sql:$HOME/.pki/nssdb -D -n "kojiadmin - IT"
certutil -d sql:$HOME/.pki/nssdb -D -n "koji-hub - IT"

# import admin certificate
pk12util -d sql:$HOME/.pki/nssdb -i /opt/koji-clients/kojiadmin/client_browser_cert.p12 -W mypassword

# https://chromium.googlesource.com/chromium/src/+/master/docs/linux_cert_management.md

# open koji-hub in browser and login with certificate
# hit CTRL+R to reload in case of deleting of existing certificate to login with new one
google-chrome https://172.17.0.3/koji/login &

# noarch because of maven repo for maven build
kojitest add-tag destination-tag --maven-support --include-all --arches="noarch"

# arch x86_64 because of rpm repo used to create build environment
kojitest add-tag build-tag --maven-support --include-all --arches="x86_64"

# create build target
kojitest add-target build-target build-tag destination-tag

# create build group "maven-build"
kojitest add-group build-tag maven-build

# populate the "maven-build" group with packages that will be installed into the build environment (buildroot)
kojitest add-group-pkg build-tag maven-build bash coreutils git java-1.8.0-openjdk-devel maven3 shadow-utils

# add external repo to download rpms into build environment (buildroot)
kojitest add-external-repo -t build-tag buil-external-repo http://myorg.com/rpm-repo/\$arch/
# or
# import packages ...


# example of importing external archives
# resolve imported dependency (all artifacts for given gav)
mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:get -DrepoUrl=http://central.maven.org/maven2/ -Dartifact=org.apache.maven.plugins:maven-enforcer-plugin:1.4:pom
mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:get -DrepoUrl=http://central.maven.org/maven2/ -Dartifact=org.apache.maven.plugins:maven-enforcer-plugin:1.4:jar
mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:get -DrepoUrl=http://central.maven.org/maven2/ -Dartifact=org.apache.maven.plugins:maven-enforcer-plugin:1.4:jar -Dclassifier=javadoc
mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:get -DrepoUrl=http://central.maven.org/maven2/ -Dartifact=org.apache.maven.plugins:maven-enforcer-plugin:1.4:jar -Dclassifier=sources

# import maven artifacts of imported package
kojitest import-archive --create-build --type maven --type-info ~/.m2/repository/org/apache/maven/plugins/maven-enforcer-plugin/1.4/maven-enforcer-plugin-1.4.pom org.apache.maven.plugins-maven-enforcer-plugin-1.4-1 ~/.m2/repository/org/apache/maven/plugins/maven-enforcer-plugin/1.4/maven-enforcer-plugin-1.4.jar ~/.m2/repository/org/apache/maven/plugins/maven-enforcer-plugin/1.4/maven-enforcer-plugin-1.4-javadoc.jar ~/.m2/repository/org/apache/maven/plugins/maven-enforcer-plugin/1.4/maven-enforcer-plugin-1.4.pom ~/.m2/repository/org/apache/maven/plugins/maven-enforcer-plugin/1.4/maven-enforcer-plugin-1.4-sources.jar

# add package
kojitest add-pkg --owner kojiadmin build-tag org.apache.maven.plugins-maven-enforcer-plugin

# tag package build
kojitest tag-pkg build-tag org.apache.maven.plugins-maven-enforcer-plugin-1.4-1


# make sure followin list is not empty othewise maven repo is not generated
kojitest list-tagged --inherit build-tag

# repo regen
kojitest regen-repo build-tag

# verify maven repo was generated - maven repo root should be displayed
google-chrome https://172.17.0.3/kojifiles/repos/build-tag/latest/maven/ &

# add package
kojitest add-pkg --owner=kojiadmin destination-tag myproject
# submit maven build
kojitest maven-build build-target https://www.github.com/myorg/myproject

~~~~
