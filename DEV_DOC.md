# DEV_DOC.md

# Developer Documentation

This document describes how to set up, build, and maintain the Inception project from a developer's perspective.

---

# Prerequisites

Before building the project, ensure the following software is installed:

* Docker
* Docker Compose
* GNU Make

The project is intended to be developed and executed inside the provided virtual machine.

---

# Project Structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each service has its own Dockerfile and configuration files.

---

# Configuration

## Environment Variables

General configuration is stored in:

```text
srcs/.env
```

Typical variables include:

MYSQL_DATABASE – MariaDB database name.
MYSQL_USER – MariaDB user created for WordPress.
DOMAIN_NAME – Domain used to access the website.
WP_TITLE – Title of the WordPress website.
WP_ADMIN_USER and WP_ADMIN_EMAIL – WordPress administrator account information.
WP_USER and WP_EMAIL – Default WordPress author account information.

The `.env` file is loaded automatically by Docker Compose.

---

## Secrets

Sensitive information is stored separately in the `secrets/` directory.

Example:

```text
secrets/
├── credentials.txt
├── db_password.txt
├── db_root_password.txt
└── wp_author_password.txt
```

Passwords should never be hardcoded into Dockerfiles or committed to a public repository.

---

# Building and Launching

The project is managed through the provided Makefile.

Build images and start the containers:

```sh
make
```

or

```sh
make up
```

This command:

* creates the required host directories
* builds every Docker image
* creates the Docker network
* creates Docker volumes
* starts every service

---

# Stopping the Project

Stop all containers:

```sh
make down
```

Containers are stopped while preserving images and persistent data.

---

# Cleaning Docker Resources

Remove containers, images, anonymous volumes, and unused Docker resources:

```sh
make clean
```

---

# Removing Persistent Data

Remove everything, including persistent data stored on the host:

```sh
make fclean
```

This command removes:

```text
/home/cwong/data/
```

including both the MariaDB database and WordPress files.

---

# Container Management

List running containers:

```sh
docker ps
```

List project containers:

```sh
docker compose -f srcs/docker-compose.yml ps
```

Restart a service:

```sh
docker compose -f srcs/docker-compose.yml restart <service>
```

Example:

```sh
docker compose -f srcs/docker-compose.yml restart wordpress
```

Open a shell inside a container:

```sh
docker exec -it <container_name> sh
```

Example:

```sh
docker exec -it wordpress sh
```

---

# Viewing Logs

Display logs from every service:

```sh
docker compose -f srcs/docker-compose.yml logs
```

Display logs from a single service:

```sh
docker compose -f srcs/docker-compose.yml logs nginx
```

```sh
docker compose -f srcs/docker-compose.yml logs wordpress
```

```sh
docker compose -f srcs/docker-compose.yml logs mariadb
```

Follow logs in real time:

```sh
docker compose -f srcs/docker-compose.yml logs -f
```

---

# Persistent Data

The project stores persistent data outside the containers.

Host directory:

```text
/home/cwong/data/
```

Contents:

```text
/home/cwong/data/mariadb
```

Stores the MariaDB database files.

```text
/home/cwong/data/wordpress
```

Stores the WordPress installation and uploaded files.

Because these directories are mounted as Docker volumes, data survives container recreation.

---

# Rebuilding After Changes

After modifying a Dockerfile or configuration file, rebuild the project:

```sh
make clean
make
```

or

```sh
make re
```

if a complete rebuild is required.

---

# Notes

* Each service runs in its own dedicated container.
* Images are built locally from custom Dockerfiles.
* Docker Compose creates a dedicated network for communication between containers.
* NGINX is the only service exposed to the host.
* MariaDB and WordPress communicate only through the internal Docker network.
* Persistent data is stored outside containers to prevent data loss during rebuilds.
