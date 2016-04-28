# Koji Dojo

Koji dojo is a suite of Docker images that are designed to enable automated testing for applications that need to integrate with Koji.

## Images

Currently, there are only two images:

* `hub/` - This is a simplistic build of the Koji hub service, configured to enable SSL authentication. It is based on the CentOS 6 Docker image
* `client/` - This is a minimal CentOS 6 image that mounts volumes from the hub container and installs the Koji client RPM from it. It will also link and configure scripts for each of the users generated in the hub setup.

## Docker Maintenance Scripts

* `build-all.sh` - Runs `docker build ...` for building the images in this repository
* `*/docker-scripts/build.sh` - Runs `docker build ...` for just the given image (hub, client, etc.)
* `*/docker-scripts/run.sh` - Starts any containers needed to support the given image, then starts a new container for the given image itself, monitoring system in/out. When you use CTL-C to escape the container, the supporting containers are stopped and removed as well.
* `*/docker-scripts/start.sh` - Starts supporting container and a new container for the given image. Each container is started in daemon mode.
* `*/docker-scripts/stop.sh` - Stops and removes the container for the given image and any supporting containers.

## Docker Compose

* Build all images: `build-all.sh`
* Start all containers: `docker-compose up` (Use -d for detached mode)
* Stop and remove all containers: `docker-compose down`

## Hub Image Notes

When the hub initializes, it checks out Koji sources from Git, builds them, and installs the koji-hub* RPMs. The sources are cloned into `/opt/koji`, which is exposed as a Docker volume. This enables the `client` image to install the client RPM that was built in conjunction with the hub RPMs.

The Koji hub image generates three users on initialization:

* kojiadmin
* testadmin
* testuser

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

## Client Image Notes

The client container mounts all exposed volumes from the hub. During initialization, it installs the Koji client RPM in `/opt/koji/noarch` (built by the hub during its own initialization), then uses the SSL configurations under `/opt/koji-clients` to generate `/root/.koji/config` with headings like `koji-testuser`. Next it symlinks `/usr/local/koji` to corresponding script names (eg. `koji-testuser`) under `/root/bin`.

Finally, the client container sets up SSH host keys and starts the SSHd daemon. It prints the IP address and port for this SSHd instance to the docker log.
