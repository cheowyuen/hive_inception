#!/bin/bash

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
WP_ADMIN_PASSWORD=$(get_secret "WP_ADMIN_PASSWORD" "/run/secrets/credentials")

mkdir -p /var/www/html

# Wait for database container to be fully alive
while ! mariadb-admin ping --protocol=tcp -h"mariadb" -u "$MYSQL_USER" --password="$DB_PASSWORD" --silent; do
    sleep 1
done

if [ ! -f "/var/www/html/wp-config.php" ]; then

    # 1. Download to correct directory
    wp core download --path=/var/www/html --allow-root

    # 2. Add --path flag so WP-CLI knows where to write config
    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb" \
        --allow-root

    # 3. Force the site URL to use HTTPS explicitly
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # 4. Check and create the author test user with path awareness
    if ! wp user get "${WP_USER}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
        wp user create \
            "${WP_USER}" \
            "${WP_EMAIL}" \
            --user_pass="${WP_PASSWORD}" \
            --role=author \
            --path=/var/www/html \
            --allow-root
    fi

    if ! wp user get "commentator" --path=/var/www/html --allow-root > /dev/null 2>&1; then
        wp user create \
            "commentator" \
            "user@42.fr" \
            --user_pass="userpassword123" \
            --role=author \
            --path=/var/www/html \
            --allow-root
    fi
fi

# Ensure PHP-FPM can listen to Nginx over the network
sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf

# 5. Grant PHP-FPM (nginx user) full write access to save evaluator edits
chown -R nginx:nginx /var/www/html

exec php-fpm82 -F

