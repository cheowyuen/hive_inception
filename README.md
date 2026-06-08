# Inception

A fully virtualized, multi-service infrastructure developed as part of the System Administration branch at Hive Helsinki (42 Network). This project orchestrates multiple Docker containers from scratch within a dedicated, secure network environment using Docker Compose on an Alpine Linux virtual machine.

## Project Architecture

The infrastructure consists of the following dedicated services:
- **NGINX**: A secure web server configured with TLSv1.2/TLSv1.3 to act as the sole entry point (Reverse Proxy).
- **WordPress**: A content management system powered by PHP-FPM (`php82`).
- **MariaDB**: A relational database server handling persistent application storage.

Security is enhanced by implementing **Docker Secrets**, ensuring that no plaintext credentials or sensitive keys are exposed via global environment variables or committed to version control.

## Directory Tree

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/ (Ignored by Git)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
