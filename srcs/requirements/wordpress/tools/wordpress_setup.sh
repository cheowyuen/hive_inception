#!/bin/bash

get_secret() {
    local secret_file_path=$1

    if [ -f "$secret_file_path" ]; then
        cat "$secret_file_path" | tr -d '\r\n'
    else
        return 1
    fi
}

DB_PASSWORD=$(get_secret "/run/secrets/db_password")
WP_ADMIN_PASSWORD=$(get_secret "/run/secrets/credentials")
WP_PASSWORD=$(get_secret "/run/secrets/wp_author_password")

mkdir -p /var/www/html

while ! mariadb-admin ping --protocol=tcp -h "mariadb" -u "$MYSQL_USER" --password="$DB_PASSWORD" --silent; do
    sleep 1
done

if [ ! -e /etc/.php_configured ]; then
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf
    touch /etc/.php_configured
fi

if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp core download --path=/var/www/html --allow-root

    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb" \
        --allow-root

    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    if ! wp user get "${WP_USER}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
        wp user create \
            "${WP_USER}" \
            "${WP_EMAIL}" \
            --user_pass="${WP_PASSWORD}" \
            --role=author \
            --path=/var/www/html \
            --allow-root
    fi
fi

chown -R nginx:nginx /var/www/html

exec php-fpm82 -F

