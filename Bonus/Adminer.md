
## Design choice

The easiest clean setup is:
* adminer container runs:  
    * PHP-FPM  
    * Adminer PHP file  
* nginx container reverse-proxies /adminer/ requests to adminer:9000  
* no extra public browser port is needed  

That keeps the same architecture already in use for WordPress:
- NGINX serves as front door  
- PHP app runs in its own internal container  

## 1 - Create folder structure 

```bash
mkdir -p ~/Inception/srcs/requirements/bonus/adminer/tools
mkdir -p ~/Inception/srcs/requirements/bonus/adminer/conf
touch ~/Inception/srcs/requirements/bonus/adminer/Dockerfile
touch ~/Inception/srcs/requirements/bonus/adminer/tools/setup.sh
chmod +x ~/Inception/srcs/requirements/bonus/adminer/tools/setup.sh
```

## 2 - Add Adminer variables to .env

```bash
# move to srcs directory where .env is
cd ~/Inception/srcs/
vim .env
# and then inside VIM, add these lines
ADMINER_PATH=/adminer
ADMINER_PORT=9000
```

There is no need to separate DB credentials for Adminer, because Adminer will connect using the same MariaDB service and the same credentials already in use:
1. server: mariadb  
2. username: from MYSQL_USER  
3. password: from MYSQL_PASSWORD  
4. database: from MYSQL_DATABASE

## 3 - Write Adminer's Dockerfile

do: `vim ~/Inception/srcs/requirements/bonus/adminer/Dockerfile`


```Dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysqli \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
```
## 4 - Write the Adminer startup script

Open: `vim ~/Inception/srcs/requirements/bonus/adminer/tools/setup.sh`

Write this:
```bash
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
```

This will:  
[1] create a web root and download the Adminer PHP file once as `index.php`
[2] configure PHP-FPM to listen on `port 9000`
[3] start PHP-FPM in foreground, which is the correct container behavior *instead of using forbidden infinite-loop tricks like tail -f or sleep infinity*  

## 5 - Add Adminer to the docker-compose file
Add this under `services`:  

```yaml
  adminer:
    container_name: adminer
    build: ./requirements/bonus/adminer
    image: adminer
    env_file:
      - .env
    depends_on:
      - mariadb
    networks:
      - inception
    restart: always
```

<details> <summary> CLICK HERE To look how the docker-compose.yml file should look like now </summary>

```yaml
services:
  mariadb:
    container_name: mariadb
    build: ./requirements/mariadb
    image: mariadb
    env_file:
      - .env
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception
    restart: always

  wordpress:
    container_name: wordpress
    build: ./requirements/wordpress
    image: wordpress
    env_file:
      - .env
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - mariadb
    networks:
      - inception
    restart: always

  adminer:
    container_name: adminer
    build: ./requirements/bonus/adminer
    image: adminer
    env_file:
      - .env
    depends_on:
      - mariadb
    networks:
      - inception
    restart: always

  nginx:
    container_name: nginx
    build: ./requirements/nginx
    image: inception-nginx
    env_file:
      - .env
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - wordpress
      - adminer
    networks:
      - inception
    restart: always
```

</details>

## 6 - Update NGINX config to route /adminer/

Adminer needs one special location block before the generic PHP block.  
- `/adminer/` goes to the **adminer container**
- `normal *.php` requests still go to **wordpress**

Open `vim ~/Inception/srcs/requirements/nginx/conf/nginx.conf`
Modify it to this new version:  

```bash
events {}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name mcalciat.42.fr;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_certificate /etc/nginx/ssl/inception.crt;
        ssl_certificate_key /etc/nginx/ssl/inception.key;

        root /var/www/html;
        index index.php index.html index.htm;

        location = /adminer {
            return 301 /adminer/;
        }

        location = /adminer/ {
            include fastcgi_params;
            fastcgi_pass adminer:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /var/www/html/index.php;
        }

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
        }
    }
}
```

## 7 - Rebuild & Test

```bash
cd ~/Inception
make clean
# if you haven't clean things before
make 
make ps
# 4th container should be visible
```

In the VM, open the browser and go to 
```
https://mcalciat.42.fr/adminer/
```
The Adminer login page should be shown.  

![Adminer Login](/pics/Adminer_login.png)

Login with the .env credentials:  
```bash
System:   MySQL
Server:   mariadb
Username: root
Password: root_pass_42
Database: wordpress
```

If the login works, you should see the wordpress database and its tables. That is proof that:
* Adminer is reachable through NGINX
* Adminer can talk to MariaDB on the Docker network
* the WordPress database is really there