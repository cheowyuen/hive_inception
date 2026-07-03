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

# 1. Prepare directory and establish safe ownership immediately
mkdir -p /var/www/html
chown -R nginx:nginx /var/www/html

# Wait for MariaDB network readiness
while ! mariadb-admin ping --protocol=tcp -h "mariadb" -u "$MYSQL_USER" --password="$DB_PASSWORD" --silent; do
    sleep 1
done

if [ ! -f "/var/www/html/wp-config.php" ]; then

    # 2. Run WP-CLI commands safely as the 'nginx' system user
    # Note: Using 'su nginx -s /bin/sh -c' executes the command as the unprivileged user
    
    su nginx -s /bin/sh -c "wp core download --path=/var/www/html"

    su nginx -s /bin/sh -c "wp config create \
        --path=/var/www/html \
        --dbname=\"${MYSQL_DATABASE}\" \
        --dbuser=\"${MYSQL_USER}\" \
        --dbpass=\"$DB_PASSWORD\" \
        --dbhost=\"mariadb\""

    su nginx -s /bin/sh -c "wp core install \
        --path=/var/www/html \
        --url=\"https://${DOMAIN_NAME}\" \
        --title=\"${WP_TITLE}\" \
        --admin_user=\"${WP_ADMIN_USER}\" \
        --admin_password=\"$WP_ADMIN_PASSWORD\" \
        --admin_email=\"${WP_ADMIN_EMAIL}\" \
        --skip-email"

    if ! su nginx -s /bin/sh -c "wp user get \"${WP_USER}\" --path=/var/www/html > /dev/null 2>&1"; then
        su nginx -s /bin/sh -c "wp user create \
            \"${WP_USER}\" \
            \"${WP_EMAIL}\" \
            --user_pass=\"${WP_PASSWORD}\" \
            --role=author \
            --path=/var/www/html"
    fi
fi

# Ensure PHP-FPM can listen to Nginx over the network
sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf

# Final structural check to ensure any dynamic generation matches permissions
chown -R nginx:nginx /var/www/html

exec php-fpm82 -F