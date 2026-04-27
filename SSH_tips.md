# Makefile commands

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

# Docker Commands

## docker --version
```bash
docker info
sudo docker run hello-world
docker ps
```

## Verify docker compose file
```bash
docker compose config
# If that prints the resolved config with no errors, the YAML is good.
```
## Start/stop Containers
```bash
docker compose up --build
docker ps
docker ps -a
docker compose down

docker compose down -v 
# (clean the  volumes!!)
```

## volumes check
```bash
docker volume ls
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```

## Mariadb 
```bash
docker compose logs mariadb
# see logs
docker exec -it mariadb bash
# enter mariadb container
mariadb -u root -p
# this will ask you for the ROOT password in .env file
SHOW DATABASES;
SELECT User, Host FROM mysql.user;
SELECT User, Host, plugin FROM mysql.user;
```

## Wordpress
```bash
docker compose logs wordpress

# to go inside the container

docker exec -it wordpress bash

# and then inside the container
cd /var/www/html
cat wp-config.php | grep DB_
grep DB_HOST /var/www/html/wp-config.php
getent hosts mariadb
```

## NGINX

```bash
docker ps
# check running containers
docker compose logs nginx
```
You want to see something like:

![docker ps test nginx](pics/nginx_ps_test.png)

Then check nginx logs:
```bash
docker compose logs nginx
curl -k https://mcalciat.42.fr
curl -k -I https://mcalciat.42.fr
```

## FULL CLEAN TEST
```BASH
docker compose down -v
sudo rm -rf /home/mcalciat/data/mysql
sudo rm -rf /home/mcalciat/data/wordpress
mkdir -p /home/mcalciat/data/mysql
mkdir -p /home/mcalciat/data/wordpress
docker compose up --build
```
This will remove all remainig hidden files from the DB.
---

# SSH

## Connect (VM running) from host
```bash
ssh <your_VM_username>@<VM_ip>
#example
ssh mcalciat@10.13.200.243
```
(use `ip a` in the VM to verify the ip)


first time -> confirm **yes** and use VM's password for that username.


## 📦 Copy files 

### 📤 Copy file FROM your local machine → VM
```bash
scp file.txt username@VM_IP:/home/username/
```
Example:
```
scp test.txt maria@192.168.1.45:/home/maria/
```

### 📥 Copy file FROM VM → your local machine
```bash
scp username@VM_IP:/home/username/file.txt .
```
Example:
```
scp maria@192.168.1.45:/home/maria/test.txt .
```

### 📤📥Copy folders FROM your local machine → VM
```bash
scp -r folder/ username@VM_IP:/home/username/
```

### 📥 Copy folder FROM VM → your local machine
```bash
scp -r mcalciat@10.13.200.243:/home/mcalciat/Inception . 
scp -r mcalciat@10.13.200.243:/home/mcalciat/data/wordpress .
scp -r mcalciat@10.13.200.243:/home/mcalciat/data/mysql . 
```

## 🔥 Generate SSH-keygen
Avoid typing password every time (SSH keys).  
On your local machine:
```bash
ssh-keygen
ssh-copy-id username@VM_IP
```

## 🧱 Connection fails (VERY common)
Check these:
🔹 1. VM network mode  
In VirtualBox settings for the VM, go to Network and check the network config:  
Use Bridged Adapter (best)  
OR  
Use NAT + port forwarding  
🔹 2. Firewall  
Inside VM:  
```bash
sudo ufw allow ssh
```
🔹 3. SSH service
```bash
sudo systemctl status ssh
```

---



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
