*This project has been created as part of the 42 curriculum by cwong*

# Inception

## Description

Inception is a system administration project that introduces Docker by building a small web infrastructure composed of multiple isolated services.

The project consists of creating custom Docker images (without using pre-built images other than the base Debian image), configuring the services, and orchestrating them with Docker Compose.

The infrastructure includes:

* NGINX configured with HTTPS (TLS 1.2/1.3)
* WordPress running with PHP-FPM
* MariaDB as the database server
* Docker volumes for persistent data
* A dedicated Docker network for inter-container communication

Each service runs inside its own container and communicates only through the Docker network.

---

# Instructions

## Prerequisites

* Docker
* Docker Compose
* GNU Make

## Build and Run

Build the images and start the containers:

```sh
make
```

or

```sh
make up
```

Stop the project:

```sh
make down
```

Remove containers and images:

```sh
make clean
```

Remove everything, including persistent data:

```sh
make fclean
```

---

# Project Description

## Why Docker?

Docker packages applications together with their dependencies into isolated containers.

This provides:

* consistent environments
* simplified deployment
* lightweight isolation
* reproducible builds

Unlike traditional installations, applications do not modify the host operating system directly.

---

## Services

The project consists of three containers:

| Service   | Purpose                             |
| --------- | ----------------------------------- |
| NGINX     | Reverse proxy and HTTPS endpoint    |
| WordPress | PHP application serving the website |
| MariaDB   | Database for WordPress              |

Only the NGINX container is accessible from outside the Docker network.

---

## Source Files

```
srcs/
├── docker-compose.yml
├── .env
└── requirements/
    ├── mariadb/
    ├── nginx/
    └── wordpress/
```

* `docker-compose.yml` defines the infrastructure.
* `.env` stores project configuration variables.
* Each service directory contains its own Dockerfile and configuration files.

---

# Design Choices

## Virtual Machines vs Docker

| Virtual Machine                            | Docker                  |
| ------------------------------------------ | ----------------------- |
| Includes a complete guest operating system | Shares the host kernel  |
| Higher resource usage                      | Lightweight             |
| Slower startup                             | Fast startup            |
| Strong hardware-level isolation            | Process-level isolation |
| Larger disk footprint                      | Smaller images          |

Docker was chosen because it provides lightweight application isolation while consuming fewer resources than virtual machines.

---

## Secrets vs Environment Variables

### Environment Variables

Environment variables are suitable for non-sensitive configuration such as:

* database name
* usernames
* domain name
* website title

### Secrets

Secrets are intended for confidential information such as passwords.

Separating secrets from configuration reduces the risk of exposing sensitive information in version control.

---

## Docker Network vs Host Network

### Docker Network

* Containers communicate through an isolated private network.
* Services are discoverable by container name.
* Only explicitly published ports are accessible from the host.

### Host Network

* Containers share the host's network stack.
* Reduced isolation.
* Greater risk of port conflicts.

A dedicated Docker bridge network improves security and matches the project requirements.

---

## Docker Volumes vs Bind Mounts

### Docker Volumes

* Managed by Docker.
* Intended for persistent application data.
* Independent of container lifetime.

### Bind Mounts

* Directly map host directories into containers.
* Useful during development.
* Depend on the host filesystem layout.

This project stores persistent WordPress and MariaDB data using Docker volumes mapped to directories under:

```
/home/cwong/data/
```

This ensures that data survives container recreation.

---

# Resources

## Documentation

* Docker Documentation
  https://docs.docker.com/

* Docker Compose Documentation
  https://docs.docker.com/compose/

* NGINX Documentation
  https://nginx.org/en/docs/

* WordPress Documentation
  https://developer.wordpress.org/

* MariaDB Documentation
  https://mariadb.com/kb/

## Video Tutorials
* Docker Crash Course for Absolute Beginners [NEW]
  https://www.youtube.com/watch?v=pg19Z8LL06w

* Docker Tutorial for Beginners [FULL COURSE in 3 Hours]
  https://www.youtube.com/watch?v=3c-iBn73dDE

* Full NGINX Tutorial – Demo Project with Node.js, Docker
  https://www.youtube.com/watch?v=q8OleYuqntY
  
* NGINX Explained – What is NGINX
  https://www.youtube.com/watch?v=iInUBOVeBCc

---

## AI Usage

AI was used as a learning aid during this project.

AI assistance included:

* explaining Docker concepts
* clarifying Docker Compose configuration
* explaining NGINX, MariaDB, and WordPress configuration
* reviewing documentation
* improving the wording and organization of the project's Markdown documentation

All project implementation, configuration, debugging, testing, and validation were completed by the author.

---

# Additional Documentation

Further documentation is available in:

* `USER_DOC.md` — End-user instructions
* `DEV_DOC.md` — Developer documentation
