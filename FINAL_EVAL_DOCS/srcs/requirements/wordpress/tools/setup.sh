#!/bin/bash
set -e

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f wp-config.php ]; then
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf wordpress latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done

until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    -e "USE ${MYSQL_DATABASE};" >/dev/null 2>&1
do
    echo "Waiting for MariaDB database/user..."
    sleep 2
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

sed -i 's|^listen = .*|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf

exec php-fpm8.2 -F
