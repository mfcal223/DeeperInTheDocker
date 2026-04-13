# General Workflow 

🪜 STEP 0 — Prepare environment
Install VM (you already know this ✅)
Install Docker + Docker Compose
🪜 STEP 1 — Project structure

Create:

Makefile
srcs/
  docker-compose.yml
  .env
  requirements/
    nginx/
    wordpress/
    mariadb/
🪜 STEP 2 — Build MariaDB container
Write Dockerfile
Configure database
Add user + DB
🪜 STEP 3 — Build WordPress container
Install:
PHP
php-fpm
WordPress
Connect to MariaDB
🪜 STEP 4 — Build NGINX container
Configure HTTPS
Reverse proxy to WordPress
🪜 STEP 5 — Volumes
Create named volumes

Map to:

/home/<login>/data
🪜 STEP 6 — Docker Compose
Connect all containers
Define network
Define volumes
🪜 STEP 7 — Domain setup

Edit /etc/hosts:

127.0.0.1  yourlogin.42.fr
🪜 STEP 8 — Security & env
.env file
Docker secrets
🪜 STEP 9 — Testing

Open browser:

https://yourlogin.42.fr
🪜 STEP 10 — Documentation
README
USER_DOC
DEV_DOC