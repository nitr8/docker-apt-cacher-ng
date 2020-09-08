# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/whumphrey/apt-cacher-ng) and is the recommended method of installation.

```bash
docker pull whumphrey/apt-cacher-ng
```

Alternatively you can build the image yourself.

```bash
docker build -t whumphrey/apt-cacher-ng .
```

## Quickstart

Start Apt-Cacher NG using:

```bash
docker run --name apt-cacher-ng --init -d --restart=always \
  --publish 3142:3142 \
  --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng \
  whumphrey/apt-cacher-ng
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

## Command-line arguments

You can customize the launch command of Apt-Cacher NG server by specifying arguments to `apt-cacher-ng` on the `docker run` command. For example the following command prints the help menu of `apt-cacher-ng` command:

```bash
docker run --name apt-cacher-ng --init -it --rm \
  --publish 3142:3142 \
  --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng \
  whumphrey/apt-cacher-ng -h

docker run -p 3142:3142 -v /Users/whumphrey/apt-cacher-ng:/var/cache/apt-cacher-ng whumphrey/apt-cacher-ng
```

## Persistence

For the cache to preserve its state across container shutdown and startup you should mount a volume at `/var/cache/apt-cacher-ng`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/apt-cacher-ng
chcon -Rt svirt_sandbox_file_t /srv/docker/apt-cacher-ng
```

## Docker Compose

To run Apt-Cacher NG with Docker Compose, create the following `docker-compose.yml` file

```yaml
---
version: '3'

services:
  apt-cacher-ng:
    image: whumphrey/apt-cacher-ng
    container_name: apt-cacher-ng
    ports:
      - "3142:3142"
    volumes:
      - apt-cacher-ng:/var/cache/apt-cacher-ng
    restart: always

volumes:
  apt-cacher-ng:
```

The Apt-Cache NG service can then be started in the background with:

```bash
docker-compose up -d
```

## Usage

To start using Apt-Cacher NG on your Debian (and Debian based) host, create the configuration file `/etc/apt/apt.conf.d/01proxy` with the following content:

```config
Acquire::HTTP::Proxy "http://172.17.0.1:3142";
Acquire::HTTPS::Proxy "false";
```

Similarly, to use Apt-Cacher NG in you Docker containers add the following line to your `Dockerfile` before any `apt-get` commands.

```dockerfile
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
```

## Logs

To access the Apt-Cacher NG logs, located at `/var/log/apt-cacher-ng`, you can use `docker exec`. For example, if you want to tail the logs:

```bash
docker exec -it apt-cacher-ng tail -f /var/log/apt-cacher-ng/apt-cacher.log
```

# Maintenance

## Cache expiry

Using the [Command-line arguments](#command-line-arguments) feature, you can specify the `-e` argument to initiate Apt-Cacher NG's cache expiry maintenance task.

```bash
docker run --name apt-cacher-ng --init -it --rm \
  --publish 3142:3142 \
  --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng \
  whumphrey/apt-cacher-ng -e
```

The same can also be achieved on a running instance by visiting the url http://localhost:3142/acng-report.html in the web browser and selecting the **Start Scan and/or Expiration** option.

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull whumphrey/apt-cacher-ng:latest
  ```

  2. Stop the currently running image:

  ```bash
  docker stop apt-cacher-ng
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v apt-cacher-ng
  ```

  4. Start the updated image

  ```bash
  docker run --name apt-cacher-ng --init -d \
    [OPTIONS] \
    whumphrey/apt-cacher-ng
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it apt-cacher-ng bash
```
