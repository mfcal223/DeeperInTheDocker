- [General Workflow](#general-workflow)
  - [🪜 STEP 0 — Prepare environment](#-step-0--prepare-environment)
    - [A. Install a Virtual Machine (VM)](#a-install-a-virtual-machine-vm)
    - [B. Set up OpenSSH to communicate between your PC and your VM](#b-set-up-openssh-to-communicate-between-your-pc-and-your-vm)
    - [B. Install Docker + Docker Compose](#b-install-docker--docker-compose)
    - [C. Configure Docker volume storage location](#c-configure-docker-volume-storage-location)
  - [🪜 STEP 1 — Project structure](#-step-1--project-structure)
  - [🪜 STEP 2 — Build MariaDB container](#-step-2--build-mariadb-container)
    - [🧼 Reset \& re-testing](#-reset--re-testing)
    - [📯 Recap of Step-2](#-recap-of-step-2)
  - [🪜 STEP 3 — Build WordPress container](#-step-3--build-wordpress-container)
    - [🧱 1. Create files](#-1-create-files)
    - [🐳 2. Dockerfile](#-2-dockerfile)
    - [⚙️ 3. WordPress setup script](#️-3-wordpress-setup-script)
    - [🧩 4. docker-compose (WordPress part)](#-4-docker-compose-wordpress-part)
    - [💾 5. Verify .env](#-5-verify-env)
    - [🧪 6. Test WordPress container](#-6-test-wordpress-container)
    - [🚨 8. Common mistakes](#-8-common-mistakes)
    - [9. 🧠 Recap](#9--recap)
  - [🪜 STEP 4 — Build NGINX container](#-step-4--build-nginx-container)
    - [1. Create the nginx files](#1-create-the-nginx-files)
    - [2. NGINX Dockerfile](#2-nginx-dockerfile)
    - [3. NGINX configuration](#3-nginx-configuration)
    - [4. NGINX setup script](#4-nginx-setup-script)
    - [5. Add nginx service to docker-compose](#5-add-nginx-service-to-docker-compose)
    - [6. Check .env](#6-check-env)
    - [7. 📡 Update /etc/hosts in the VM](#7--update-etchosts-in-the-vm)
    - [8. Validate compose file before building](#8-validate-compose-file-before-building)
    - [9. Build and run](#9-build-and-run)
    - [10. Check containers](#10-check-containers)
    - [11. First connectivity tests](#11-first-connectivity-tests)
    - [12. Issues](#12-issues)
  - [🪜 STEP 5 — Makefile](#-step-5--makefile)
  - [🪜 STEP 6 — Testing](#-step-6--testing)
  - [🪜 STEP 7 — Security Warnings \& Documentation](#-step-7--security-warnings--documentation)

---

# General Workflow 

## 🪜 STEP 0 — Prepare environment

### A. Install a Virtual Machine (VM)

1. download Debian 12.9
https://cdimage.debian.org/cdimage/archive/12.9.0/amd64/iso-cd/
https://cdimage.debian.org/cdimage/archive/12.9.0/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso

2. open Virtual Box, create a NEW virtual machine.
user: mcalciat
pwd: inception42
ram size: 2 GB
processors: 2 CPU
Disk size: 20 GB

3. Go to Settings > Network and change NAT to Bridged Adapter. You will need to to setup an SSH connection.

4. Once in the VM, check sudo is installed:  
* apt install sudo (if not installed). Insert the same password you choose when installing the VM when asked.
* in a terminal, add your user to sudo: `usermod -aG sudo <your_user>`
    * this way you can execute admin commands without being in "sudo"
    * check: `sudo whoami` (shoudl reply "root")


### B. Set up OpenSSH to communicate between your PC and your VM

- OpenSSH server → runs inside your VM  
- OpenSSH client → runs on your local machine  

👉 This lets you:  
* Connect to your VM terminal remotely  
* Copy files between machines  
* Automate workflows  

In the VM, install OpenSSH and check if it is running:
```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl status ssh
```

If it is **NOT** running:
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

Find the VM's IP address
```bash
ip a
```
You should see 192.168.x.x 

From the host PC
```bash
ssh <your_user>@<VM_ip>
```
for example
```bash
ssh maria@192.128.2.5
```

First time it will ask to confirm `yes`, and then to re-type the VM `password`.

4. Install curl  
`curl` is a tool to download data from the internet via terminal.  

Debian’s default repositories may have older Docker versions. This project expects a proper, up-to-date Docker setup: download `Docker’s official GPG key`.  

> “Only trust packages from Docker if they are signed with this official key”.  
> This verifies the packages are authentic (not tampered).  
> Without a GPG key, anyone could fake a package and make an user install malware instead of Docker.  

After installing curl, create a directory where the system will store trusted GPG keys (like Docker’s key).
Download Docker’s public signing key, and convert it into a format usable by APT and save it.

**Run**: 
```bash
sudo apt install curl -y

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

5. Add Docker's official repository to the system

**Run:**
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

### B. Install Docker + Docker Compose  

🚀 **Step 1 — Install Docker**  
```bash
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
**What is this installing?**  
| Package                 | Role                                 |
| ----------------------- | ------------------------------------ |
| `docker-ce`             | Main Docker engine                   |
| `docker-ce-cli`         | Command-line interface (`docker`)    |
| `containerd.io`         | Container runtime (low-level engine) |
| `docker-compose-plugin` | Enables `docker compose`             |

⚙️ **Step 2 — Start Docker service**
```bash
sudo systemctl start docker
```
This starts the Docker daemon (the “engine” running in background)


👉 *Optional but recommended*
```bash
sudo systemctl enable docker
```
*This makes Docker start automatically on boot*


🧪 **Step 3 — Test installation**
* Check version  ---> Docker CLI is installed and working
```bash
docker --version
```
![docker version](pics/docker_version.png)
* check Docker's info 
```bash 
docker info
```
![docker info](pics/docker_info.png)


* Hello world Test ---> Docker daemon is working and containers run correctly
```bash
sudo docker run hello-world
```
Now:
* Docker pulls a tiny test image
* Runs it in a container
* Prints a success message

![succes docker message](/pics/docker_test.png)

🚨🚨 If there is a permissions error in the version or info test:
```
sudo usermod -aG docker $USER
```
and `exit` ssh connection, and `restart` the VM.

### C. Configure Docker volume storage location

The subject requires using **Docker named volumes**, but it also says that the volume data must be stored inside:

```bash
/home/<login>/data
```
At first, it may seem easier to force this path directly inside docker-compose.yml using `driver_opts`, `device`, and` o: bind`.
However, that creates a *bind mount behavior*, and bind mounts are *not allowed* by the subject.  

To keep the project compliant, the docker-compose.yml must use real Docker named volumes, without driver_opts.  

To make Docker store those named volumes under /home/<login>/data, configure Docker’s own storage directory.   
This ensures that Docker named volumes are stored in a location that complies with the subject requirements, without using bind mounts.  

> ⚠️ This configuration must be applied before running `make` for the first time.  
> If Docker volumes were already created, they must be removed (`docker compose down -v`) before applying this configuration.

```bash
# stop docker
sudo systemctl stop docker
# Create the required data directory
sudo mkdir -p /home/mcalciat/data/docker
# Edit Docker’s daemon configuration:
sudo vim /etc/docker/daemon.json
# Add this content: 
{
  "data-root": "/home/mcalciat/data/docker"
}
# Reload systemd and restart Docker:
sudo systemctl daemon-reload
sudo systemctl start docker
```

To verify Docker is using the correct storage location 
```bash
docker info | grep "Docker Root Dir"
# the expected output is :
Docker Root Dir: /home/mcalciat/data/docker
```

---

## 🪜 STEP 1 — Project structure

Create:
```
Makefile  
srcs/
  docker-compose.yml
  .env
  requirements/
    nginx/
    wordpress/
    mariadb/
```
**Use:**
```bash
mkdir -p ~/Inception/srcs
mkdir -p ~/Inception/srcs/requirements/mariadb/{conf,tools}
mkdir -p ~/Inception/srcs/requirements/nginx/{conf,tools}
mkdir -p ~/Inception/srcs/requirements/wordpress/{conf,tools}
mkdir -p ~/Inception/srcs/requirements/tools
touch ~/Inception/Makefile
touch ~/Inception/srcs/docker-compose.yml
touch ~/Inception/srcs/.env
```

Then check it:
```bash
tree ~/Inception
# or, if tree is not installed:
find ~/Inception -type d -o -type f | sort
```

Because the subject requires that persistent data is stored inside `/home/<login>/data`, Docker must be configured to use that location for its internal storage.

Create the base directory:

```bash
mkdir -p /home/mcalciat/data/docker
```

There is no need to manually create `/mysql` or `/wordpress` folders, because the project is using proper Docker named volumes. Docker manages the internal volume structure automatically under its data root directory, which I configured to `/home/mcalciat/data/docker`.  
Docker named volumes are used instead of bind mounts because they are managed by Docker and provide better isolation, portability, and compliance with the subject requirements.  

---

## 🪜 STEP 2 — Build MariaDB container
Recap on the subject’s mandatory rules:
```
[a] one dedicated container for MariaDB
[b] built from your own Dockerfile
[c] no ready-made MariaDB image
[d] database data persisted in a named volume
[e] credentials passed through environment variables, not hardcoded in Dockerfile
```

Create 3 files for MariaDB:
```bash
touch srcs/requirements/mariadb/Dockerfile
touch srcs/requirements/mariadb/conf/50-server.cnf
touch srcs/requirements/mariadb/tools/setup.sh
chmod +x srcs/requirements/mariadb/tools/setup.sh
```
1. Write Dockerfile
```bash
FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
```

2. Configure database
```bash
[mysqld]
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock
pid-file = /run/mysqld/mysqld.pid
```

`bind-address = 0.0.0.0` allows **MariaDB** to accept connections from the **WordPress** container through the Docker network.  
If it stayed only on localhost, WordPress would not be able to connect.  

3. Write startup script: add user + DB
Inside setup.sh there will a script in charge of launching, creating DB, sql user and password. The container keeps running with MariaDB as the main process.

```bash
#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -f "/var/lib/mysql/.setup_done" ]; then
    mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --pid-file=/run/mysqld/mysqld.pid --skip-networking &
    pid="$!"

    until mariadb --protocol=socket -u root -e "SELECT 1;" >/dev/null 2>&1; do
        sleep 1
    done

    mariadb --protocol=socket -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.setup_done

    mariadb-admin --protocol=socket -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

exec mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --pid-file=/run/mysqld/mysqld.pid
```
These lines: 
```bash
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql
```
help avoid startup errors related to:
- missing socket directory  
- wrong ownership on DB files  
- MariaDB not being able to write its pid/socket

These lines: `/var/lib/mysql/.setup_done` will:
- first launch → create DB/user/passwords, then create marker
- next launches → skip setup safely

4. Include mariadb's setup script variables in `.env`
MariaDB's setup.sh script expects the definition of those variables it uses.   
These need to be placed in`.env` when we wire MariaDB into `docker-compose.yml`.
Fill `.env` with these lines:
```bash
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wp_pass_42
MYSQL_ROOT_PASSWORD=root_pass_42

MYSQL_VOLUME=/home/mcalciat/data/mysql
WP_VOLUME=/home/mcalciat/data/wordpress
DOMAIN_NAME=mcalciat.42.fr
```

Remember this : 
> MYSQL_ROOT_PASSWORD=root_pass_42

5. Write mariadb's docker compose info 
Open the file
```bash
vim ~/Inception/srcs/docker-compose.yml
```
Include mariaDB verision:
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

volumes:
  mariadb_data:
    name: mariadb_data

networks:
  inception:
    driver: bridge
```

This will **build the image** from the Dockerfile, **name the image mariadb** (which matches the service name), **load the .env** variables, **mounts the named volume** int mysql (where the data is stored). In case of crash, there are **instruction to restart**. 
It also creates the `Docker network` that will connect mariadb to `WordPress` and `NGINX`.

6. Test mariadb
Use:
```bash
cd ~/Inception/srcs
docker compose up --build
```
On first launch, MariaDB should:
- build the image  
- initialize the DB  
- create the database  
- create the SQL user  
- stay running

If you want to stop it, use:
```bash
docker compose down
```
If you want to stop and remove volumes too:
```bash
docker compose down -v
```
🚨🚨 Be careful:`-v` deletes persisted DB data.🚨🚨

If asked `Watch` versus `Detach`, recommendation is `detach`, and it will run in the background. Choosing watch means you'll be watching logs in real time. The terminal is "blocked". That is useful only for debugging.

In another terminal, do:
```bash
# to see it running
docker ps
# to see logs
docker compose logs mariadb
```

7. Database validation
Seeing logs prove the server is running, but to actually confirm that the database was created, the SQL user was created and the root password was applied, do as follows:
```bash
docker exec -it mariadb bash
```
Then inside the container
```
mariadb -u root -p
```
Enter the root password from `.env`

Then run:
```bash
SHOW DATABASES;
# check the custom database exists
SELECT User, Host FROM mysql.user;
# checks the custom user exists
SELECT User, Host, plugin FROM mysql.user;
# shows how each user authenticates to MariaDB
```

![mariadb test](pics/mariadb_test.png)
To exit, just type `exit` twice.

`plugin` check is done to verify that MariaDB users use **password-based authentication (mysql_native_password) instead of socket-based authentication**, which would prevent WordPress from connecting through the Docker network.

```bash
root   | localhost | mysql_native_password
wpuser | %         | mysql_native_password
```
- root uses password → OK ✅  
- wpuser uses password → OK ✅  
- wpuser can connect from anywhere → OK ✅  

8. Exit Maria DB  
⛔️ To **exit** MariaDB, just type `exit` twice.   
Once to exit MariaDB itself, and 2nd time to exit root.

### 🧼 Reset & re-testing
If you need to `RE test` because you found an error, do a **full reset** because the current `MariaDB volume` already contains partially initialized data. It should be reseted before retesting, or the old state may remain. 
```bash
cd ~/Inception/srcs
docker compose down -v
sudo rm -rf /home/mcalciat/data/mysql
mkdir -p /home/mcalciat/data/mysql
```
 Then rebuild:
```
docker compose up --build
```

### 📯 Recap of Step-2
If all went well, MariaDB step is now working correctly:
* container runs         
* custom DB created      
* custom SQL user created 
* root configured         
* mariaDB files were created: Dockerfile, config, init script.
* docker compose file was created
* volumen mount and DB/user validation

Make a BACKUP copy of these files:
```bash
srcs/requirements/mariadb/Dockerfile
srcs/requirements/mariadb/conf/50-server.cnf
srcs/requirements/mariadb/tools/setup.sh
srcs/docker-compose.yml
srcs/.env
```

---

## 🪜 STEP 3 — Build WordPress container

🎯 Goal recap:
* installing php-fpm  (❌ no nginx)
* downloading/configuring WordPress  
* connecting WordPress to MariaDB using:  
      * database name: wordpress  
      * user: wpuser  
      * host: mariadb  
* mounting the WordPress files volume
* communicate through Docker network

### 🧱 1. Create files
```bash
cd ~/Inception/srcs/requirements/wordpress

touch Dockerfile
mkdir -p tools
touch tools/setup.sh
chmod +x tools/setup.sh
```

### 🐳 2. Dockerfile
```Dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
```

until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
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
`RUN` is installing or updating:  
* `php-fpm` → runs PHP server (NGINX will connect later)
* `php-mysql` → allows WordPress ↔ MariaDB communication
* `curl` → to download WordPress

Then it copies the setup script and makes that script executable (avoid permission errors).

It sets port 9000 (typically php-fpm for WordPress) as the port the container will listen (metadata for container-to-container communication patterns). 
Finally it sets the main startup command of the container: the script that will run everytime the container starts.


### ⚙️ 3. WordPress setup script

tools/setup.sh
```bash
#!/bin/bash
set -e

# Create directory
mkdir -p /var/www/html
cd /var/www/html

# Download WordPress (only first time)
if [ ! -f wp-config.php ]; then
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf wordpress latest.tar.gz

    # Configure wp-config.php
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

#Wait for mariaDB to create the DB
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done

# configure Wordpress
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

# Configure PHP-FPM to listen on all interfaces
sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf

# Run php-fpm in foreground (IMPORTANT for Docker)
exec php-fpm -F
```

🧠 Key Concepts (VERY IMPORTANT)
🔗 1. Database connection
```
define('DB_HOST', 'mariadb');
```

👉 This is NOT localhost
👉 This is the container name (Docker DNS)

💾 2. Volume usage
WordPress files live in:
```
/var/www/html
```

👉 This is stored in a Docker named volume.
👉 The actual files are located under Docker's data root:
```bash
/home/<login>/data/docker/volumes/wordpress_data/_data
```

🌐 3. php-fpm (port 9000)
WordPress does NOT serve HTTP
It only processes PHP
NGINX will connect to: `wordpress:9000`

### 🧩 4. docker-compose (WordPress part)
Modify the docker-compose file to look like this:  
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

volumes:
  mariadb_data:
    name: mariadb_data
  wordpress_data:
    name: wordpress_data

```

### 💾 5. Verify .env 
Check that it contains these lines: 
```
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wp_pass_42

WP_VOLUME=/home/mcalciat/data/wordpress
```

### 🧪 6. Test WordPress container
```
docker compose up --build
```
Then:
```bash
docker ps -a
# List current containers
docker compose logs wordpress
# List logs. Sometimes there will be none and it's OK
docker exec -it wordpress ps aux
# list all running processes in the container
```
You can confirm WordPress(WP) files exists in the volume
```bash
ls -la /home/mcalciat/data/docker/volumes/
```
you should see files like 
```
wp-config.php
wp-admin
wp-content
wp-includes
index.php
```

![wordpress files exist check](pics/wordpress_file_creation_check.png)

Afterward you can check inside the WP container: 
```bash
docker exec -it wordpress bash
#to enter it
cd /var/www/html
cat wp-config.php | grep DB_
# Confirm wp-config.php contains the right DB values for the DB connection config
getent hosts mariadb
# test if WP can resolve the MariaDB container name
```
![WP config check](pics/wordpress_check_DB_connection_config.png)


### 🚨 8. Common mistakes 

| Issue   | Cause | Check:  |
|---------|-------|-------------------|
|WordPress cannot connect to DB | MariaDB not ready yet |  restart logic |
|Blank page | php-fpm not running correctly |  **docker exec -it wordpress bash** + **ps aux** | **grep php-fpm** |
| Files not persisting | volume not mounted correctly | **ls /home/mcalciat/data/wordpress** |.

### 9. 🧠 Recap
WordPress container:
- stores files → volume
- runs php-fpm → port 9000
- connects to DB → mariadb container  

If all went well, now WordPress container is correctly built and running, it is correctly connected to MariaDB, the volumes and network are working.
No HTTP server and no NGINX are used in this container.



---

## 🪜 STEP 4 — Build NGINX container
This will add the *only public entrypoint of the project*:  
1. NGINX  
2. HTTPS only  
3. TLS 1.2 / 1.3 only  
4. reverse proxy using FastCGI to wordpress:9000 

> 🧭 **At the end of this step, the flow will be:**
```yaml
Browser → NGINX:443 → WordPress:9000 → MariaDB:3306
```

### 1. Create the nginx files

From your project root:
```bash
touch ~/Inception/srcs/requirements/nginx/Dockerfile
touch ~/Inception/srcs/requirements/nginx/conf/nginx.conf
touch ~/Inception/srcs/requirements/nginx/tools/setup.sh
chmod +x ~/Inception/srcs/requirements/nginx/tools/setup.sh
```

### 2. NGINX Dockerfile
Inside `srcs/requirements/nginx/Dockerfile`
```Dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup.sh"]
```

### 3. NGINX configuration
Inside `srcs/requirements/nginx/conf/nginx.conf`
```conf
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

### 4. NGINX setup script
Inside `srcs/requirements/nginx/tools/setup.sh`
```bash
#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=LU/ST=Luxembourg/L=Luxembourg/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
```

This is good for the project because:

no infinite loop
nginx stays in foreground as PID 1
TLS cert gets created inside the container
no password is hardcoded in Dockerfile

### 5. Add nginx service to docker-compose

Your docker-compose.yml should now become this:
```bash
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

  nginx:
    container_name: nginx
    build: ./requirements/nginx
    image: nginx
    env_file:
      - .env
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - wordpress
    networks:
      - inception
    restart: always

volumes:
  mariadb_data:
    name: mariadb_data
  wordpress_data:
    name: wordpress_data

networks:
  inception:
    driver: bridge
```

> **Important notes:** nginx mounts the same wordpress_data volume as read access path for site files.  
> That way:
> - WordPress writes files there
> - NGINX serves them from there


### 6. Check .env

Make sure this exists in `srcs/.env`:
```bash
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wp_pass_42
MYSQL_ROOT_PASSWORD=root_pass_42

MYSQL_VOLUME=/home/mcalciat/data/mysql
WP_VOLUME=/home/mcalciat/data/wordpress
DOMAIN_NAME=mcalciat.42.fr

WP_TITLE=Inception WordPress

WP_ADMIN_USER=guildMaster
WP_ADMIN_PASSWORD=1234shouldnotbeapassword
WP_ADMIN_EMAIL=guildmaster@example.com

WP_USER=normal_user
WP_USER_PASSWORD=myn0rm4lp4ss
WP_USER_EMAIL=just_one_user@example.com
```

### 7. 📡 Update /etc/hosts in the VM

Inside the VM, edit:
```bash
sudo vim /etc/hosts
```

Add this line:
```text
127.0.0.1 mcalciat.42.fr
```

> **This is needed because the subject wants your domain name to resolve locally.**


### 8. Validate compose file before building
```bash
cd ~/Inception/srcs:
docker compose config
```
If that prints the resolved config with no errors, the YAML is good.

### 9. Build and run
```bash
docker compose up --build
```
You should expect:
- mariadb up
- wordpress up
- nginx up

```bash
[+] up 7/7
 ✔ Image wordpress        Built              5.9s
 ✔ Image inception-nginx  Built              5.9s
 ✔ Image mariadb          Built              5.9s
 ✔ Network srcs_inception Created            0.0s
 ✔ Container mariadb      Created            0.1s
 ✔ Container wordpress    Created            0.0s
 ✔ Container nginx        Created            0.0s
Attaching to mariadb, nginx, wordpress
```
### 10. Check containers

In another terminal:
```bash
docker ps
```
You want to see something like:

![docker ps test nginx](pics/nginx_ps_test.png)

Then check nginx logs:
```bash
docker compose logs nginx
```
If all is fine, it may be mostly quiet, or you'll see:  
![nginx logs](pics/nginx_logs.png)

### 11. First connectivity tests

Inside the VM, try:
```bash
curl -k https://mcalciat.42.fr

curl -k -I https://mcalciat.42.fr
# The -k is because the certificate is self-signed.
# -I is to inspect the headers
```
A healthy result would look like HTTP/1.1 200 OK or possibly a redirect depending on WordPress state.

```bash
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Tue, 21 Apr 2026 08:45:33 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
Link: <https://mcalciat.42.fr/index.php?rest_route=/>; rel="https://api.w.org/"
```

### 12. Issues
If `nginx` fails, the most common causes are:  
`A`. host not found in upstream "wordpress"
That means nginx cannot resolve the WordPress container name.
Check:
- docker exec -it nginx getent hosts wordpress

`B`. connect() failed (111: Connection refused)
That usually means WordPress/php-fpm is not listening on 9000.
Check:
- docker exec -it wordpress ps aux

`C`. SSL file issue
If cert paths are wrong, nginx logs will complain about missing .crt or .key.

`D`. Wrong server_name
Make sure server_name in nginx.conf matches DOMAIN_NAME.


---

## 🪜 STEP 5 — Makefile

```makefile
NAME        = inception
COMPOSE     = docker compose -f srcs/docker-compose.yml
DATA_PATH   = /home/mcalciat/data
MYSQL_DIR   = $(DATA_PATH)/mysql
WP_DIR      = $(DATA_PATH)/wordpress

all: up

up: create_dirs
	$(COMPOSE) up --build -d

build: create_dirs
	$(COMPOSE) build

down:
	$(COMPOSE) down

start: create_dirs
	$(COMPOSE) up -d

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps

create_dirs:
	mkdir -p $(MYSQL_DIR)
	mkdir -p $(WP_DIR)

clean: down
	$(COMPOSE) down -v

fclean: down
	$(COMPOSE) down -v --rmi all
	sudo rm -rf $(MYSQL_DIR)
	sudo rm -rf $(WP_DIR)
	mkdir -p $(MYSQL_DIR)
	mkdir -p $(WP_DIR)

re: fclean up

.PHONY: all up build down start stop restart logs ps create_dirs clean fclean re
```

`COMPOSE` → avoids repeating the full docker compose command.  
`DATA_PATH` → central place to define where volumes live.  
`make`  → default command for evaluation. Same as doing `make up`.  
`make up`  → creates required folders, builds images, starts containers IN THE background.  
`make build`  → Builds images only (no container start) if you modify Dockerfiles.  
`make down `  → Stops and removescontainers and network (DOES NOT REMOVE VOLUMES, data stays).  
`make start `  → Starts containers without rebuilding (to be use after `make down`).  
`make stop`  → Stops containers but keeps them available to restart.  
`make restart`  → make down + make up.  
`make logs`  → Shows logs from all containers. Useful for debugging.  
`make ps`  → Shows container status.  
`make create_dirs`  →  Creates directories for volumes. Ensures host directories exist before Docker mounts volumes.  

`make clean`  → stops containers + removes volumes. It does NOT delete /home/mcalciat/data/* (data still exists).  
`make fclean`  → FULL RESET: removes containers + removes volumes + removes images + deletes ALL data folders (including hidden files!) + recreates empty directories.  

---

## 🪜 STEP 6 — Testing
```bash
make

#check that containers exist, are running
docker ps
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx

# check volumes exist
ls -la /home/mcalciat/data
ls -la /home/mcalciat/data/mysql
ls -la /home/mcalciat/data/wordpress
docker volume ls

ls -la /home/username/data
ls -la /home/username/data/mysql
ls -la /home/username/data/wordpress
docker volume ls

# Confirm Docker stores its data under `/home/<login>/data`
docker info | grep "Docker Root Dir"

# Verify Docker named volumes 
docker volume inspect mariadb_data
docker volume inspect wordpress_data

#check mariadb
docker exec -it mariadb mariadb -u root -p
SHOW DATABASES;
SELECT User, Host FROM mysql.user;

#check wordpress users exists
docker exec -it wordpress wp user list --allow-root --path=/var/www/html

#check nginx/TLS
curl -kI https://mcalciat.42.fr
openssl s_client -connect mcalciat.42.fr:443 -tls1_2
openssl s_client -connect mcalciat.42.fr:443 -tls1_3

curl -kI https://username.42.fr
openssl s_client -connect username.42.fr:443 -tls1_2
openssl s_client -connect username.42.fr:443 -tls1_3
```


In the VM, open browser:
```
https://<yourlogin>.42.fr
```
The Hello World wordpress web should appear. 
![hello world](pics/WPsite_helloworld.png)

Scroll down and leave a comment. 

Then, go to the login
```
https://<yourlogin>.42.fr/wp-admin
```
Use the admin credentials that were created, and gain access to the user panel. You can then check if both users are there...

![wp user settings](pics/WPsite_usersTable.png)

As admin, you can approve the comment that was submitted. Then refresh the home site, and check if the comment is there. 

To test permanence of information, use `make restart` and/or `make clean` (NOT fclean or the information will be deleted). Once everything is up again, you can check the website again, and re-validate users are there, and the comment is there too. 

---

## 🪜 STEP 7 — Security Warnings & Documentation

⚠️ The `.env` file must NOT be committed to the repository.  
Add it to `.gitignore` before pushing your project.

README
USER_DOC
DEV_DOC