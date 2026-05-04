#!/bin/bash
set -e

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f index.php ]; then
    curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o index.php
fi

mkdir -p /run/php

sed -i 's|^listen = .*|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf
sed -i 's|^;clear_env = no|clear_env = no|' /etc/php/*/fpm/pool.d/www.conf || true

	exec php-fpm8.2 -F
