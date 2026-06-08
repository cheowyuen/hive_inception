#!/bin/sh

get_secret() {
    local env_var_name=$1
    local secret_file_path=$2
    
    if [ -f "$secret_file_path" ]; then
        cat "$secret_file_path"
    else
        echo "${!env_var_name}"
    fi
}

DB_PASSWORD=$(get_secret "MYSQL_PASSWORD" "/run/secrets/db_password")
DB_ROOT_PASSWORD=$(get_secret "MYSQL_ROOT_PASSWORD" "/run/secrets/db_root_password")

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    cat << EOF > /tmp/init_db.sql
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

    mysqld --user=mysql --bootstrap < /tmp/init_db.sql
    rm -f /tmp/init_db.sql
fi

exec mysqld --user=mysql
