# Bonus

## 🔅 Implementation order 
| Order | Bonus                              | Why do it now                              |
| ----- | ---------------------------------- | ------------------------------------------ |
| 1     | **Adminer**                        | Easiest to add and test                    |
| 2     | **Redis + WordPress Redis plugin** | Very useful, moderate difficulty           |
| 3     | **FTP server**                     | Straightforward once WP volume is stable   |
| 4     | **Static website**                 | Easy, but you must decide how to expose it |
| 5     | **Extra useful service**(*)           | Do last, after the required bonus items    |



(*) Example: backup service: A simple backup container is easier to defend and safer for evaluation:
- periodically copy WordPress files and/or MariaDB dumps into a backup folder
- very useful, easy to explain, easy to build from Debian with your own Dockerfile

---

##  Adminer
Purpose

Adminer gives you a web UI to inspect the MariaDB database.

Container logic
one dedicated adminer container
install PHP + light web server or PHP-FPM + web server inside that container
connect it to the same Docker network as MariaDB
no need for persistent volume unless you want custom config
Access

Best option:

reverse proxy it through NGINX at /adminer/

---

Redis cache for WordPress
Goal

Use Redis as an object cache for WordPress.

Needed pieces
a redis container
WordPress configured to talk to redis
usually a WordPress Redis plugin
optional: define Redis host in wp-config.php
Docker design
redis service on same network
no public port needed
likely a dedicated named volume is optional, but nice to have
Important note

This is not page caching through NGINX.
This is usually WordPress object cache through Redis.

Validation idea

Inside WordPress:

plugin active
Redis connection successful
cache enabled
Defense sentence

Redis improves performance by storing frequently used data in memory, reducing repeated database queries from WordPress to MariaDB.

---

FTP server
Goal

Provide FTP access to the same WordPress files volume.

The subject explicitly says the FTP container must point to the volume of your WordPress website.

Container logic
dedicated ftp service
mount the same wordpress_data volume
create FTP user from env vars
choose passive mode ports carefully
Important design note

FTP is one of the few bonus services where opening extra ports makes sense.

Ports

Typical:

21 for control
passive range, for example 30000-30009

Since bonus allows extra ports, that is acceptable.

Risk to control

Permissions.

The FTP user must be able to read/write the WordPress files correctly without breaking ownership expected by the wordpress container.

So this part needs care:

same UID/GID strategy if possible
or controlled ownership/chmod during container setup

---

Static website
Requirement

Simple static site in any language except PHP.

Best choice

Use:

plain HTML/CSS
maybe a little JS

That is enough.

Container logic
dedicated static-site container
small web server, or NGINX serving static files
its own Dockerfile
optionally no volume needed if files are copied at build time
Routing

Best through the main NGINX:

/resume/
or /portfolio/
What to build

Given your profile, a very simple personal showcase site would be perfect:

name
short intro
transition from medicine to tech
project highlights
contact links

This is easy, quick, and looks polished.

---

Extra useful service: backup service
Why I recommend this instead of something flashier

Because it is:

useful
simple
easy to justify
directly relevant to infrastructure administration
What it can do

A backup container could:

create a MariaDB dump
copy WordPress files to a backup directory
store backups in a dedicated volume
Defense sentence

I added a backup service because WordPress and MariaDB contain persistent application data. In a real deployment, having automated backups is an essential operational safeguard.

That is a very strong justification.

Caveat

Avoid making it too complex.
A simple manually triggered backup container is enough.

---

What your compose file will need conceptually

Your current compose has 3 services.
You would extend it with something like:

redis
ftp
adminer
static_site
backup

All on the same inception network.

Likely extra volumes

You may want:

redis_data
backup_data

The FTP service should reuse:

wordpress_data

Adminer probably needs no persistent volume.

Static site likely needs no persistent volume unless you want runtime editing.

---

Suggested folder structure

A clean extension of your current tree would be:

srcs/
  docker-compose.yml
  .env
  requirements/
    mariadb/
    nginx/
    wordpress/
    bonus/
      redis/
        Dockerfile
        conf/
        tools/
      ftp/
        Dockerfile
        conf/
        tools/
      adminer/
        Dockerfile
        conf/
        tools/
      static_site/
        Dockerfile
        website/
      backup/
        Dockerfile
        tools/

This also fits nicely with the subject’s sample structure that shows a bonus folder under requirements.

What to add to .env

You already use .env correctly for the mandatory part.

For bonus, add new env vars like:

REDIS_HOST=redis
REDIS_PORT=6379

FTP_USER=ftpuser
FTP_PASSWORD=some_strong_password
FTP_PORT=21
FTP_PASSIVE_MIN=30000
FTP_PASSIVE_MAX=30009

ADMINER_PORT=8080   # only if you expose directly
STATIC_SITE_NAME=resume

BACKUP_PATH=/backup

For evaluation safety, I would also improve your existing passwords before final submission, because your current .env contains obvious placeholder/demo credentials.

Best practical strategy
Phase 1 — easiest wins
Add Adminer
Add static site

These two are low risk and help you confirm your reverse-proxy pattern.

Phase 2 — infrastructure extras
Add Redis
Add FTP

These require a bit more coordination with WordPress.

Phase 3 — last polish
Add backup service
What I would avoid
Avoid doing all five at once

Too risky.
If one service breaks NGINX routing or compose startup, debugging becomes annoying.

Avoid direct exposure of everything

You can open extra ports for bonus, but it is cleaner to keep:

browser services behind NGINX
only FTP with extra ports
maybe backup with no public ports at all
Avoid complicated extra services

Do not pick something hard to justify or debug, like a full monitoring stack, unless you really want it.