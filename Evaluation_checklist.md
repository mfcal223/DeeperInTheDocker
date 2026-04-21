# Evaluation Checklist
| Subject condition                                 |                     Status | Validation                                                                           |
| ------------------------------------------------- | -------------------------: | ------------------------------------------------------------------------------------ |
| Project done in a VM                              |                          ✅ | Confirmed by your Debian VM workflow and runtime session                             |
| `srcs/` folder required                           |                          ✅ | Present in project structure and compose setup                                       |
| Root `Makefile` required                          |                          ✅ | Present in uploaded project files                                                    |
| Must use Docker Compose                           |                          ✅ | `docker-compose.yml` is used and the stack starts correctly                          |
| One container per service                         |                          ✅ | `mariadb`, `wordpress`, `nginx` each run separately                                  |
| Own images, one per service                       |                          ✅ | Runtime now shows images named `mariadb`, `wordpress`, `nginx`                       |
| NGINX container only                              |                          ✅ | nginx service is separate and fronts the stack                                       |
| WordPress + php-fpm only, without nginx           |                          ✅ | wordpress container is separate and nginx forwards php requests to `wordpress:9000`  |
| MariaDB only, without nginx                       |                          ✅ | separate MariaDB service, no port published externally                               |
| Dedicated Docker network required                 |                          ✅ | custom bridge network `inception` exists                                             |
| No `network: host`, no `links`                    |                          ✅ | compose uses a normal custom bridge network                                          |
| Two named volumes required                        |                          ✅ | `srcs_mariadb_data`, `srcs_wordpress_data` exist                                     |
| DB volume persists under `/home/login/data`       |                          ✅ | `/home/mcalciat/data/mysql` contains MariaDB data                                    |
| WP files volume persists under `/home/login/data` |                          ✅ | `/home/mcalciat/data/wordpress` contains WordPress files                             |
| Restart on crash                                  |                          ✅ | `restart: always` for all services                                                   |
| NGINX only entrypoint on 443                      |                          ✅ | only nginx publishes `443:443`                                                       |
| TLS 1.2 or 1.3 only                               |                          ✅ | `ssl_protocols TLSv1.2 TLSv1.3;` configured                                          |
| Domain must be `<login>.42.fr`                    |                          ✅ | `mcalciat.42.fr` in `.env` and nginx config                                          |
| `.env` mandatory                                  |                          ✅ | `.env` present and used by compose                                                   |
| No passwords in Dockerfiles                       | ✅ / not fully audited here | no evidence of hardcoded passwords in uploaded config snippets                       |
| WordPress DB must have 2 users, one admin         |                          ✅ | env and setup indicate admin + normal user creation                                  |
| Admin username must not contain admin             |                          ✅ | `guildMaster` respects the rule                                                      |


| Subject requirement                                       |            Status | Why                                                                                                                                |
| --------------------------------------------------------- | ----------------: | ---------------------------------------------------------------------------------------------------------------------------------- |
| Project uses Docker Compose                               |                 ✅ | The subject requires docker compose. Your stack is defined in `docker-compose.yml`.                                                |
| 3 mandatory services: nginx / wordpress+php-fpm / mariadb | ✅ / partly proven | Compose defines the three services, and your WordPress setup script ends with `php-fpm8.2 -F`, which supports the php-fpm part.    |
| Dedicated container per service                           |                 ✅ | One service block per container.                                                                                                   |
| Network between containers                                |                 ✅ | Custom bridge network `inception` is present.                                                                                      |
| Containers restart on crash                               |                 ✅ | `restart: always` is set on all three services.                                                                                    |
| NGINX only entrypoint via port 443                        |                 ✅ | Only nginx publishes a port, and it is `443:443`.                                                                                  |
| TLS 1.2 / 1.3 only                                        |                 ✅ | `ssl_protocols TLSv1.2 TLSv1.3;` is configured.                                                                                    |
| Domain name uses `<login>.42.fr`                          |                 ✅ | `.env` and nginx config use `mcalciat.42.fr`.                                                                                      |
| Two persistent storages (DB + WP files)                   |                 ✅ | `mariadb_data` and `wordpress_data` are declared and mounted.                                                                      |
| Data stored under `/home/login/data`                      |                 ✅ | `.env` points to `/home/mcalciat/data/mysql` and `/home/mcalciat/data/wordpress`.                                                  |
| Environment variables + `.env`                            |                 ✅ | Required by subject and present in your compose/env files.                                                                         |
| WordPress admin user not named admin                      |                 ✅ | Admin user is `guildMaster`, which respects the rule.                                                                              |
| WordPress includes a second user                          |                 ✅ | The setup script creates an additional user with `wp user create`.                                                                 |





🧱 Core infrastructure

| Requirement                       | Status | Proof / How to verify                                                           |
| --------------------------------- | -----: | ------------------------------------------------------------------------------- |
| Project runs in a VM              |      ✅ | Terminal prompt shows Debian VM session (`mcalciat@Inception`)                  |
| Uses Docker Compose               |      ✅ | `docker compose -f srcs/docker-compose.yml up` runs successfully                |
| `Makefile` at root builds project |      ✅ | You ran `make` → containers built and started                                   |
| Files under `srcs/`               |      ✅ | `docker compose -f srcs/docker-compose.yml` path confirms structure             |
| One container per service         |      ✅ | `docker ps` → shows `mariadb`, `wordpress`, `nginx`                             |
| Custom images (not pulled)        |      ✅ | `docker ps` → IMAGE names match your services (`mariadb`, `wordpress`, `nginx`) |

🐳 Containers & services
| Requirement              | Status | Proof / How to verify                                              |
| ------------------------ | -----: | ------------------------------------------------------------------ |
| MariaDB container only   |      ✅ | `docker ps` → mariadb has only `3306/tcp` (not exposed externally) |
| WordPress + php-fpm only |      ✅ | `docker ps` → wordpress exposes `9000/tcp`, nginx handles HTTP     |
| NGINX container only     |      ✅ | `docker ps` → nginx is separate container                          |
| Containers are running   |      ✅ | `docker ps` → all 3 containers `Up`                                |
| Restart policy active    |      ✅ | `docker-compose.yml` shows `restart: always`                       |

🌐 Networking
| Requirement                         | Status | Proof / How to verify                                              |
| ----------------------------------- | -----: | ------------------------------------------------------------------ |
| Custom Docker network               |      ✅ | `docker compose ps` → all services attached to `inception` network |
| No host networking / no links       |      ✅ | `docker-compose.yml` uses `driver: bridge`, no `network: host`     |
| Inter-container communication works |      ✅ | nginx → wordpress via `fastcgi_pass wordpress:9000`                |

💾 Volumes & persistence
| Requirement                          | Status | Proof / How to verify                                           |
| ------------------------------------ | -----: | --------------------------------------------------------------- |
| Two named volumes exist              |      ✅ | `docker volume ls` → `srcs_mariadb_data`, `srcs_wordpress_data` |
| DB volume persists data              |      ✅ | `ls /home/mcalciat/data/mysql` → MariaDB files present          |
| WP volume persists files             |      ✅ | `ls /home/mcalciat/data/wordpress` → WordPress files present    |
| Volumes stored in `/home/login/data` |      ✅ | `.env` → `/home/mcalciat/data/...`                              |
| Data persists across runs            |      ✅ | presence of `.setup_done` and DB files in volume                |

🔐 Access / security / routing
| Requirement               | Status | Proof / How to verify                                 |
| ------------------------- | -----: | ----------------------------------------------------- |
| Only nginx exposes ports  |      ✅ | `docker ps` → only nginx has `0.0.0.0:443->443/tcp`   |
| Only port 443 exposed     |      ✅ | `docker ps` → no `80`, no `3306`, no `9000` exposed   |
| Domain is `<login>.42.fr` |      ✅ | `.env` → `mcalciat.42.fr`                             |
| Site reachable via HTTPS  |      ✅ | `curl -kI https://mcalciat.42.fr` → `HTTP/1.1 200 OK` |
| TLS enabled               |      ✅ | `openssl s_client -connect mcalciat.42.fr:443`        |
| TLS 1.2 / 1.3 only        |      ✅ | nginx config → `ssl_protocols TLSv1.2 TLSv1.3`        |

🗄️ Database (MariaDB)
| Requirement        | Status | Proof / How to verify                                   |
| ------------------ | -----: | ------------------------------------------------------- |
| MariaDB is running |      ✅ | `docker compose logs mariadb` → “ready for connections” |
| Database created   |      ✅ | `SHOW DATABASES;` → includes `wordpress`                |
| SQL user created   |      ✅ | `SELECT User, Host FROM mysql.user;` → `wpuser`         |
| DB accessible      |      ✅ | Connected using `mariadb -u root -p`                    |


🌍 WordPress
| Requirement               | Status | Proof / How to verify                                     |
| ------------------------- | -----: | --------------------------------------------------------- |
| WordPress installed       |      ✅ | `/home/mcalciat/data/wordpress` → wp files exist          |
| WordPress served by nginx |      ✅ | `curl` → returns WordPress headers                        |
| WordPress connected to DB |      ✅ | Site returns 200 OK (not DB error page)                   |
| Admin user exists         |      ✅ | `wp user list` → `guildMaster`                            |
| Admin not named “admin”   |      ✅ | username = `guildMaster`                                  |
| Second user exists        |      ✅ | `wp user list` → `normal_user`                            |
| WordPress CLI works       |      ✅ | `docker exec wordpress wp user list --path=/var/www/html` |

⚙️ Environment & secrets
| Requirement                  |         Status | Proof / How to verify                                        |
| ---------------------------- | -------------: | ------------------------------------------------------------ |
| `.env` file used             |              ✅ | `docker-compose.yml` → `env_file: .env`                      |
| Credentials injected via env |              ✅ | Variables used in setup scripts (`MYSQL_USER`, etc.)         |
| No passwords in Dockerfiles  |             ✅* | No evidence in uploaded configs (*manual code review needed) |
| `.env` not committed         | ⚠️ must ensure | `.gitignore` should include `.env`                           |
