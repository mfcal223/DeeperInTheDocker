*This project has been created as part of the 42 curriculum by* ***mcalciat.***

# Inception

## 📌 Description
This project focuses on building a small infrastructure using Docker containers, all running inside a virtual machine.  The goal is to create multiple isolated services that work together as a complete web application stack.  

> The infrastructure is composed of three main services: 
* `NGINX` → Web server with HTTPS (TLS 1.2 / 1.3)
* `WordPress + PHP-FPM` → Application layer
* `MariaDB` → Database

Each service runs in its **own container** and communicates through a dedicated **Docker network**.

> The project focuses on:
1. Understanding containerization.  
2. Managing service orchestration with Docker Compose.  
3. Ensuring data persistence with volumes.  
4. Configuring secure web access via HTTPS.  

---

## 🏗️ Project Architecture
```bash
     Browser
        ↓
  NGINX (443 HTTPS)
        ↓
 ┌───────────────┐
 │               │
WordPress     Adminer
   ↓              ↓
       MariaDB
```

* Only NGINX exposes a public port (443).  
* All services communicate internally via Docker network.  
* Data is persisted using Docker volumes.  

---

## ⚙️ Project Structure
```bash
.
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
        └── bonus/
            └── adminer/
```
All configuration files are located inside the `srcs/` directory, as required by the subject.  

---

## 📦 Docker & Design Choices

`Docker` is a software platform that allows you to build, test, and deploy applications quickly. It is an operating system for `containers`.   
Docker provides the ability to package and run an application in a loosely isolated environment called a **container**. The isolation and security let you run many containers simultaneously on a given host.

When you use Docker, you are creating and using images, containers, networks, volumes, plugins, and other objects.
- `Image` → blueprint of a service  
- `Container` → running instance of an image  
- `Volume` → persistent data storage  
- `Network` → communication layer between containers  

Each service (NGINX, WordPress, MariaDB) runs in its own container and communicates through the Docker network.  

### 🖥️ Virtual Machines vs Docker

> Why use Docker instead of a Virtual Machien (VM)?

| Feature            | Virtual Machine        | Docker                     |
|--------------------|------------------------|----------------------------|
| OS                 | Full OS per instance   | Shared host kernel         |
| Size               | Heavy (GBs)            | Lightweight (MBs)          |
| Startup time       | Slow                   | Fast                       |
| Isolation          | Strong (hardware-level)| Process-level isolation    |

👉 Docker was chosen because it is lightweight, faster, and ideal for microservice-based architectures.

### 🔐 Secrets vs Environment Variables

> What are the options a person can use to store sensitive information?

* Environment variables (.env)  → like writing your password on a sticky note
      * Used for configuration (database name, user, domain)  
      * Plain text file  
      * Injects variables into containers at startup  
      * Easy to use → but not secure by design  

* Docker secrets  → like storing it in a locked drawer and giving controlled access
      * Recommended for sensitive data (passwords, keys)
      * Exposed to containers as temporary files in memory  
      * Not stored in the image, not visible in `docker inspect`  

| Feature             | `.env` file               | Docker Secrets                        |
| ------------------- | ------------------------- | ------------------------------------- |
| Storage             | Plain text on disk        | Managed by Docker                     |
| Encryption          | ❌ No                      | ⚠️ Depends (*)                |
| Visibility          | Visible via env / inspect | Hidden from inspect                   |
| Access in container | Environment variables     | Mounted as files (`/run/secrets/...`) |
| Security level      | Low                       | High                                  |

( * ) *In `Docker Swarm`, the information is encrypted at rest and in transit. In `Docker Compose` (like in this project) it woulod NOT be fully secure.*

👉 In this project, `.env` is used for simplicity, but in production environments, `Docker secrets` should be preferred for security.

### 🌐 Docker Network vs Host Network

> Why does Docker use its own private network?

* Host Network  
    * Containers share host networking.  
    * Less isolation.  
    * Forbidden in the subject.  
* Docker bridge network  
    * Private internal network -> "private LAN between containers".  
    * Only exposed ports are reachable from outside.  
    * Containers communicate via service names using internal DNS (their container names act as hostnames).

👉 This project uses a custom Docker bridge network, ensuring isolation and compliance.

A `Docker bridge network` creates a private internal network where containers can communicate securely using their service names. This network is isolated from the host and external devices, meaning that services are not accessible unless explicitly exposed through a port. For example, even if someone is connected to the same Wi-Fi as the host machine, they cannot access the database container unless a port is explicitly published.

### 💾 Docker Volumes vs Bind Mounts

> Why does the subject forbids the use of bind mounts?

* Bind mounts  👉 it directly links a container folder to a specific folder on your host.
    * Direct mapping to host filesystem
        * Container writes directly into `/home/user/mysql`
    * Less portable 👉 Docker has no control over it.  
        * The container depends on that exact host path.  
    * ❌ Not allowed in this project.  
    * Example:
```yaml
volumes:
  - /home/user/mysql:/var/lib/mysql

# or a bind mount disguised as a volume
driver_opts:
  type: none
  o: bind
```
* Docker named volumes  
    * Managed by Docker  
    * Safer and portable  
    * Required by subject
    * Example:
```yaml
volumes:
  - mariadb_data:/var/lib/mysql
# Docker manages it internally 
/var/lib/docker/volumes/mariadb_data/_data
# (or the custom data-root)
/home/<username>>/data/docker
```

👉 This project uses Docker named volumes, configured so that data is stored under:
```bash
/home/<login>/data
```
---

# Resources:
1. [Dockerdocs - What is Docker?](https://docs.docker.com/get-started/docker-overview/)
2. [GfG - Waht is Docker?](https://www.geeksforgeeks.org/devops/introduction-to-docker/)
3. [MariaDB.org](https://mariadb.org/en/)
4. [Writing a Dockerfile](https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/)
5. [Writing a Dockerfile: Beginners to Advanced](https://dev.to/prodevopsguytech/writing-a-dockerfile-beginners-to-advanced-31ie)
6. [Docker Compose - GfG](https://www.geeksforgeeks.org/devops/docker-compose/)
7. [Use Docker Compose](https://docs.docker.com/get-started/workshop/08_using_compose/)
8. [How To Create docker-compose.yml file](https://stackoverflow.com/questions/60984684/how-to-create-docker-compose-yml-file)
9. [WordPress development environment with Docker](https://medium.com/@richardevcom/wordpress-development-environment-with-docker-ba52427bdd65)
10. [WordPress Development with Docker: A Complete Setup Guide ](https://dev.to/caffinecoder54/wordpress-development-with-docker-a-complete-setup-guide-24cb)
11. [NGINX](https://nginx.org/)
12. [Adminer](https://www.adminer.org/)
13. [How to use the Adminer image](https://hub.docker.com/_/adminer/)

---

# 🤖 AI Usage

AI tools were used during this project for:
* Clarification on Docker concepts and architecture.  
* Debugging container communication issues. 
* Reviewing configuration files (Dockerfiles, docker-compose.yml).  
* Reviewing documentation: checking spelling and grammar issues, and improving clarity.  

> All generated content was reviewed, tested, and validated manually to ensure correctness and full understanding.

---

# ⚠️ Security Notes

> `.env` FILE

The `.env` file contains ***sensitive credentials*** and must not be committed to the repository.   
It should be included in `.gitignore` and provided separately during evaluation if needed.  

> Docker Data-root

The Docker data-root directory is created during environment preparation because Docker needs this path before it can store images, containers, and volumes there.  
The Makefile also checks that the directory exists before launching the project. However, the Makefile does not configure Docker itself; it only prepares the expected folder if needed.  

**Do not manually delete `/home/<login>/data/docker` while Docker is using it as its data-root**.  
This directory contains Docker’s internal storage, including images, containers, build cache, and named volumes.

---

# Instructions
This is how to start the evaluation: 

1. Once the VM is up & running, download the project's repository in `home/`.
2. For security reasons, there is a file containing passwords and key information that was NOT uploaded into the repository (`.env` file ).
    1. Execute
```bash
    cd <Inception_repository>
    cp /home/mcalciat/ENV_FILE_IS_HERE/.env srcs/.env
```
   2. OR do it manually:  
      1. In Home, go to directory `ENV_FILE_IS_HERE`.  
      2. Copy the file (you might need to activate the option "show hidden files").  
      3. Paste it in `Inception_repository/srcs`.  
3. Open a new terminal for the project's root folder (where the **Makefile** is) and execute: `make`.   
 
Docker will build the container, mount the volumes and once the process is finished, you should be able to access the website: `https://<username>.42.fr`

* for further User Instructions [CLICK here](USER_DOC.md)  
* for further Developer Instructions [CLICK here](DEV_DOC.md)  

---
