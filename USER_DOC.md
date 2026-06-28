# USER_DOC.md

## User Documentation

This document explains how to use and manage the Inception project after it has been set up.

---

# Services Provided

The project consists of three Docker containers:

| Service       | Description                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| **NGINX**     | Provides HTTPS access to the website using TLS 1.2/1.3. This is the only service exposed to the host. |
| **WordPress** | Hosts the WordPress website using PHP-FPM.                                                            |
| **MariaDB**   | Stores the WordPress database.                                                                        |

Persistent data is stored on the host machine under:

```
/home/cwong/data/
```

* WordPress files

```
/home/cwong/data/wordpress
```

* MariaDB database

```
/home/cwong/data/mariadb
```

---

# Starting the Project

From the project root, run:

```sh
make
```

or

```sh
make up
```

This command:

* creates the required data directories
* builds all Docker images
* starts every container in the background

---

# Stopping the Project

To stop all running containers:

```sh
make down
```

The containers will stop, but all website and database data will remain.

---

# Removing Everything

To remove containers, images, volumes, and all persistent data:

```sh
make fclean
```

**Warning:** This permanently deletes the WordPress website and MariaDB database.

---

# Accessing the Website

Open the website using:

```sh
chrome https://cwong.42.fr
```

Since the project uses HTTPS with a self-signed certificate, your browser may display a security warning the first time you visit the site. Proceed by accepting the certificate.

---

# Accessing the WordPress Administration Panel

Open:

```
https://cwong.42.fr/wp-admin
```

Log in using:

* **Username:** value of the WordPress administrator username stored in `srcs/.env`
* **Password:** stored in

```
secrets/credentials.txt
```

After logging in, you can manage posts, pages, users, themes, and plugins through the WordPress dashboard.

---

# Credentials

The project stores configuration in two locations.

### Environment Variables

General configuration (database name, usernames, domain name, etc.) is stored in:

```
srcs/.env
```

### Secret Files

Passwords are stored inside the `secrets/` directory.

Available secret files include:

```
secrets/db_root_password.txt
secrets/db_password.txt
secrets/credentials.txt
secrets/wp_author_password.txt
```

These files should never be committed to a public Git repository.

---

# Checking That Services Are Running

List running containers:

```sh
docker ps
```

You should see three running containers:

* nginx
* wordpress
* mariadb

Alternatively, use:

```sh
docker compose -f srcs/docker-compose.yml ps
```

---

# Quick Reference

| Action                           | Command                                          |
| -------------------------------- | ------------------------------------------------ |
| Build and start                  | `make`                                           |
| Stop containers                  | `make down`                                      |
| Remove containers/images         | `make clean`                                     |
| Remove everything including data | `make fclean`                                    |
| View running containers          | `docker ps`                                      |
| Website                          | `https://cwong.42.fr`                            |
| Admin panel                      | `https://cwong.42.fr/wp-admin`                   |
