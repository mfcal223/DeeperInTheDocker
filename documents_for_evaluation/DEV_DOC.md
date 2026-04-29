# DEVELOPER DOCUMENTATION

## 📌 Overview

This document explains how to set up, build, and manage the project from scratch.

The project is a Docker-based infrastructure composed of:

* NGINX
* WordPress (PHP-FPM)
* MariaDB
* Adminer (bonus)

---

#### *Note*:   
In any of the commands where the `<login>` or `<username>` is requiered, please remeber to **REPLACE** it with the `your username!`

---

## ⚙️ Prerequisites

* Debian-based system (Virtual Machine recommended)
* Docker and Docker Compose installed
* Sudo privileges
* `curl` installed.

---

## 🪜 Environment Setup

### Install Docker

```bash
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
Start Docker service:
```bash 
sudo systemctl start docker
```

**Optional**: make Docker start automatically on boot.
```bash
sudo systemctl enable docker
```

#### Test Installation
```bash
# Check version  ---> Docker CLI is installed and working
docker --version
# check Docker's info
docker info
# Hello world Test ---> Docker daemon is working and containers run correctly
sudo docker run hello-world
```

🚨 If there is a permissions error in the version or info test: 🚨
```bash
sudo usermod -aG docker $USER
```
**Log out** and **restart** the VM.

---

### Configure Docker data-root

The project requires Docker volumes to be stored under:

```bash
/home/<login>/data
```

To configure this:

```bash
sudo systemctl stop docker
sudo mkdir -p /home/<login>/data/docker
sudo vim /etc/docker/daemon.json
```

Add:

```json
{
  "data-root": "/home/<login>/data/docker"
}
```

Then restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl start docker
```

Verify configuration::

```bash
docker info | grep "Docker Root Dir"

# the expected output is :
Docker Root Dir: /home/<login>/data/docker
```

---

## 📁 Project Structure

```bash
.
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            └── adminer/
```

---

## 🚀 Build and Launch

From the project root:

```bash
make
```

This will:

* Build all Docker images
* Create containers
* Start services in the background

---

## 🧰 Container Management

### Check running containers

```bash
docker ps
```
You should see:

* NGINX
* WordPress
* MariaDB
* Adminer 

This also confirms that `port 443` is the only exposed port.

---


### Stop containers

```bash
make down
```

---

### Restart containers

```bash
make restart
```

---

### Clean containers and volumes

```bash
make clean
```

---

### Full reset (⚠️ deletes all data)

```bash
make fclean
```

---

## 💾 Data Persistence

The project uses **Docker named volumes**:

* `mariadb_data` → database files
* `wordpress_data` → website files

These volumes are stored under:

```bash
/home/<login>/data/docker
```

This ensures:

* Data persists after container restart
* Data is isolated from the host filesystem
* Compliance with project requirements

---

## 🔍 Debugging & Verification


### Docker Compose logs

In `srcs/`
```bash
docker compose -f docker-compose.yml logs
```

### Check volumes

In `srcs/`
```bash
docker volume ls
# check Mountpoint (Docker data root)
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```


---

### Ensure containers are built either from the penultimate stable version of Alpine or Debian.
```bash
grep -R "^FROM" srcs/requirements
```

Expected :  
```bash
srcs/requirements/mariadb/Dockerfile:FROM debian:bookworm
srcs/requirements/wordpress/Dockerfile:FROM debian:bookworm
srcs/requirements/nginx/Dockerfile:FROM debian:bookworm
srcs/requirements/bonus/adminer/Dockerfile:FROM debian:bookworm
```

Project is using Debian Bookworm (12), not the latest version. 

All containers are built from Debian Bookworm, which is the current stable Debian release. I explicitly specify the version in the Dockerfiles instead of using latest, to ensure reproducibility and compliance with the subject requirements.

---

### MariaDB access

In `srcs/`
```bash
# see logs
docker compose logs mariadb
# enter mariaDB container (will ask for ROOT password in .env file)
docker exec -it mariadb mariadb -u root -p
# once inside
SHOW DATABASES;
SELECT User, Host FROM mysql.user;
SELECT User, Host, plugin FROM mysql.user;
```

To exit MariaDB, type `exit`.

---

### WordPress container

In `srcs/`
```bash
# check logs
docker compose logs wordpress
# Sometimes there may be no output, which is normal.
```

---

### Network test

In `srcs/`
```bash
# test if WP can resolve the MariaDB container name
docker exec -it wordpress getent hosts mariadb
```

Expected output:  
```bash
xxx.xx.x.x      mariadb
```

---

### NGINX

In `srcs/`
```bash
docker compose logs nginx
```
You should see output similar to:  

![docker ps test nginx](pics/nginx_ps_test.png)



### Test website availability

```bash
# extense message
curl -k https://<login>.42.fr
# shorter message
curl -k -I https://<login>.42.fr
```

> `REPLACE <login> with the your username!`
(If you see a **"-bash: login: No such file or directory"** message, check that you have replace it correctly)


Expected result:
```
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Tue, 28 Apr 2026 09:41:33 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
Link: <https://<login>.42.fr/index.php?rest_route=/>; rel="https://api.w.org/"
```
## Ensure that a SSL/TLS certificate is used
```bash
openssl s_client -connect username.42.fr:443 -tls1_2
openssl s_client -connect username.42.fr:443 -tls1_3
```
---

## ⚠️ Notes

* The `.env` file must be provided manually and must not be committed
* Only port **443** is exposed externally
* All services communicate through a Docker bridge network

---


# Changing a service

**Example**: changing the exposed port for the domain.

The URL will become 
```bash
https://<login>.42.fr:8443
```

1. change port on docker-compose file
```bash
#original
443:443
#new
8443:443
```

2. Update WordPress internal URLs:
```bash
#then modify wp URL information
docker exec -it wordpress \
wp option update home "https://mcalciat.42.fr:8443" \
--allow-root --path=/var/www/html

docker exec -it wordpress wp option update siteurl "https://mcalciat.42.fr:8443" --allow-root --path=/var/www/html

```

WordPress stores the URL in the database, so when the exposed port changes, I update home and siteurl using wp-cli inside the container.

3. Now, go up to root directory and do `make restart`. 
  
4. Check that the website now is available on domain 
```bash
https://<login>.42.fr:8443
```

Or you can check it via command
```bash
docker exec -it wordpress wp option get home --allow-root --path=/var/www/html

docker exec -it wordpress wp option get siteurl --allow-root --path=/var/www/html
```

## Restore the port

1. revert the changes in docker-compose.yml
2. Do:
```bash
docker exec -it wordpress wp option update home "https://mcalciat.42.fr" --allow-root --path=/var/www/html
```

Now do `make restart` and check that the website now is available on its original domain 
```bash
https://<login>.42.fr/
```

Or you can check it via command
```bash
docker exec -it wordpress wp option get home --allow-root --path=/var/www/html
docker exec -it wordpress wp option get siteurl --allow-root --path=/var/www/html
```