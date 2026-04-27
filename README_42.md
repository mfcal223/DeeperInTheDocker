*This project has been created as part of the 42 curriculum by mcalciat.*

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
WordPress (php-fpm :9000)
   ↓
MariaDB (3306)
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

## 🧠 Design Choices

### 🖥️ Virtual Machines vs Docker
### 🖥️ Virtual Machines vs Docker

| Feature            | Virtual Machine        | Docker                     |
|--------------------|------------------------|----------------------------|
| OS                 | Full OS per instance   | Shared host kernel         |
| Size               | Heavy (GBs)            | Lightweight (MBs)          |
| Startup time       | Slow                   | Fast                       |
| Isolation          | Strong (hardware-level)| Process-level isolation    |

👉 Docker was chosen because it is lightweight, faster, and ideal for microservice-based architectures.

### 🔐 Secrets vs Environment Variables
* Environment variables (.env)
      * Used for configuration (database name, user, domain)  
* Docker secrets  
      * Recommended for sensitive data (passwords)

👉 In this project, `.env` is used for simplicity, but in production environments, `Docker secrets` should be preferred for security.

### 🌐 Docker Network vs Host Network
* Host Network  
    * Containers share host networking  
    * Less isolation  
    * Forbidden in the subject  
* Docker bridge network  
    * Private internal network 
    * Containers communicate via service names

👉 This project uses a custom Docker bridge network, ensuring isolation and compliance.

### 💾 Docker Volumes vs Bind Mounts
Bind mounts
Direct mapping to host filesystem
Less portable
❌ Not allowed in this project
Docker named volumes
Managed by Docker
Safer and portable
Required by subject

👉 This project uses Docker named volumes, configured so that data is stored under:
```bash
/home/<login>/data
```
---

# 📦 Docker Concepts (Summary)
- `Image` → blueprint of a service  
- `Container` → running instance of an image  
- `Volume` → persistent data storage  
- `Network` → communication layer between containers  

Each service (NGINX, WordPress, MariaDB) runs in its own container and communicates through the Docker network.  


## What is DOCKER?
Docker is an open-source platform that uses `OS-level virtualization` to deliver software in packages called `containers`. It allows developers to bundle applications with all necessary dependencies—code, runtime, and libraries—ensuring software runs consistently across different computing environments.  
`It uses **fewer resources than virtual machines** because containers share the host machine's OS kernel`.

> "Containers are lightweight and contain everything needed to run the application, so you don't need to rely on what's installed on the host. You can share containers while you work, and be sure that everyone you share with gets the same container that works in the same way."(1)

Docker uses a `client-server architecture`. The Docker client talks to the Docker daemon, which does the heavy lifting of building, running, and distributing your Docker containers. The Docker client and daemon can run on the same system, or you can connect a Docker client to a remote Docker daemon.(1)

### Advatanges of Docker:
* `Portability`: Runs anywhere in local machine, cloud, on‑prem servers.  
* `Consistency`: Same behavior in development, testing, and production.  
* `Lightweight`: No full OS per app; containers share the host kernel.  
* `Scalability`: Ideal for microservices and orchestrators like Kubernetes and Docker Swarm.  
* `Efficiency`: Starts in seconds, uses fewer system resources.  

---

## Resources:
1. [dockerdocs - What is Docker?](https://docs.docker.com/get-started/docker-overview/)
2. [GfG - Waht is Docker?] (https://www.geeksforgeeks.org/devops/introduction-to-docker/)
3. [MariaDB.org](https://mariadb.org/en/)
4. [writing a Dockerfile](https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/)
5. [Writing a Dockerfile: Beginners to Advanced](https://dev.to/prodevopsguytech/writing-a-dockerfile-beginners-to-advanced-31ie)
6. [Docker Compose - GfG](https://www.geeksforgeeks.org/devops/docker-compose/)
7. [Use Docker Compose](https://docs.docker.com/get-started/workshop/08_using_compose/)
8. [How To Create docker-compose.yml file](https://stackoverflow.com/questions/60984684/how-to-create-docker-compose-yml-file)
9. [WordPress development environment with Docker](https://medium.com/@richardevcom/wordpress-development-environment-with-docker-ba52427bdd65)
10. [WordPress Development with Docker: A Complete Setup Guide ](https://dev.to/caffinecoder54/wordpress-development-with-docker-a-complete-setup-guide-24cb)
11. [NGINX](https://nginx.org/)

---

# 🤖 AI Usage

AI tools were used during this project for:
* Clarification on Docker concepts and architecture.  
* Debugging container communication issues. 
* Reviewing configuration files (Dockerfiles, docker-compose.yml).  
* Reviewing documentation: checking spelling and grammar issues, and improving clarity.  

> All generated content was reviewed, tested, and validated manually to ensure correctness and full understanding.

---

⚠️ Security Note

The `.env` file contains ***sensitive credentials*** and must not be committed to the repository.  
It should be included in `.gitignore` and provided separately during evaluation if needed.