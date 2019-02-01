# ll-docker

Repository to store all configuration and files for a cluster running LearningLocker services.

## ACKNOWLEDGEMENTS

This work is greatly inspired by [Michał Zimniewicz's repo](https://github.com/michzimny/learninglocker2-docker), [Lee Kirkland's fork](https://github.com/caperneoignis/learninglocker), [FUN's Docker implementation](https://github.com/openfun/learninglocker-docker), and [this issue](https://github.com/LearningLocker/learninglocker/issues/1281).

And obviously it works thanks to the software provided by [LearningLocker](https://github.com/LearningLocker).

Makefile for Docker inspired by [Johnny Mkhael's project](https://github.com/jmkhael/make-for-docker).

NodeJS setup script is from [NodeSource](https://github.com/nodesource/distributions)

## DISCLAIMER

This repo is a sandbox to build a LearningLocker instance that fits my development needs. It is NOT suitable for production. I do not take responsability for any problems you might encounter with it, and I WILL NOT maintain it in the long run.

## How to use

Because the application is structured in **services**, this Docker port is structured in a _cluster_ orchestrated with `docker-compose`.

### Getting started

1. Build the base images
    * `ll-app` : the application itself
    * `ll-nginx`: the NGINX reverse proxy unifying access to all services in one place
2. `docker-compose up -d`
3. Profits!

A Makefile is provided for tedious build commands.

Setup environment variables in `make.env` file. Most importantly the `DOCKER_ID` variable.

Build all things:

```bash
make build-all
```

Bring up the cluster:

```bash
docker-compose up -d
```

Create a site administrator **(First time only)**:

```bash
docker-compose exec api node cli/dist/server createSiteAdmin [email] [organization name] [password]
```

Site is now available at `localhost`.

> **WARNING**: for setups with `docker` and `docker-compose` commands used with `sudo`, use `sudo -E` to export the `PWD` env. variable. Otherwise it will be defaulted to `/tmp`

### Fine tuning the build process

Configuration is made with environment variables set in the `make.env` file. Some values will be overidden by the Dockerfile if not provided, other will not:

| Name      | Role                                     |Overriden value                 |
|-----------|------------------------------------------|--------------------------------|
|VERSION    |Tag for the future built version          |latest-dev                      |
|VERSION_NUM|Numerical tag for the future built version|                                |
|DOCKER_ID  |Id for DockerHub images                   |                                |
|IMAGE_NAME |Root name of the built images             |pleasechangetounique256bitstring|
|APP_SECRET |Secret for backend application            |                                |
|DOMAIN_NAME|Domain name for the LL application        |placeholder.name                |

Values can be overriden with command line interface:

```bash
make build-app DOCKER_ID=myawesomedockerid
```

To build only the web application:

```bash
make build-app
```

To build only NGINX:

```bash
make build-nginx
```

### Fine-tuning the cluster

#### MongoDB data persistence

Even though every test data for development purposes should be saved and inserted as an automated script, I understand that it can be tedious to recreate a site admin and client tokens for every dev sessions.
To toggle the MongoDB data persistence, {,un}comment the `volumes` entry in the `services.mongo` object of the `docker-compose.yml` configuration file.

#### Open other ports for debugging purpopes

Only the port `80` is open as a default. But other services can be accessed directly by opening ports:

* `8080` : LearningLocker HTTP API
* `3000` : LearningLocker Node Server
* `27017` : MongoDB instance

Just uncomment the corresponding lines in the `docker-compose.yml`.

## Improvements

As it is just a dev tool for my own purposes, I think lots of things could be improved, such as (but not limited to):

* Better multi-stage build based on a reference image easier to identify/to build.
* Mail and SMTP management;
* Logging configuration
* Logs recovery