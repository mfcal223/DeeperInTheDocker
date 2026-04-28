# 🧠 Core Docker Concepts  

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

## 📦 1. Image vs Container

🧩 `Docker Image`
A Docker `image` is a template / blueprint (a recipe)
* Read-only
* Built from a Dockerfile
* Contains:
    * OS (Debian/Alpine)
    * Software (nginx, php, mariadb)
    * Config

🚀 `Docker Container`
A `container` is a running instance of an image (created from the recipe).
It has its own filesystem, network and environment.  

🧠 **Example (in this  project)**: 1 service = 1 container
| Service   | Image                 | Container           |
| --------- | --------------------- | ------------------- |
| NGINX     | nginx image you build | nginx container     |
| WordPress | wordpress image       | wordpress container |
| MariaDB   | mariadb image         | mariadb container   |

---

## 💾 2. Volumes (Persistence)
Containers are ephemeral. ***If you delete container the data is lost***. 🔥
To solve this problem, it is necessary to use `Volumes`: a volume is persistent storage outside the container.  

📍 The volumes stored in `/home/login/data` can survive container restart or deletion.  

🧠 **Example (in this  project)** > create:
| Volume    | Purpose               |
| --------- | --------------------- |
| DB volume | store MariaDB data    |
| WP volume | store WordPress files |

---

### 🌐 3. Docker Network
A Docker network allows containers to communicate inside a "private LAN between containers".  
They "talk" using their container names (like hostnames).  

🧠 **Example (in this  project)**
``` bash
NGINX → WordPress → MariaDB

wordpress connects to mariadb via "mariadb:3306"
```

📍 From subject's rules: *“network: host is forbidden”*.   
👉 So: it MUST use a custom Docker network

---
## 🌍 4. Why Docker ≠ Virtual Machine

| Feature   | VM      | Docker        |
| --------- | ------- | ------------- |
| OS        | full OS | shared kernel |
| Speed     | slow    | fast          |
| Size      | GBs     | MBs           |
| Isolation | strong  | lighter       |

---
## 🔗 5. How Everything Connects (IMPORTANT)

Here is the final architecture:
```
         🌐 Browser
              ↓
        ┌───────────┐
        │  NGINX    │  (container)
        └───────────┘
              ↓
        ┌───────────┐
        │ WordPress │  (container)
        │ + php-fpm │
        └───────────┘
              ↓
        ┌───────────┐
        │  MariaDB  │  (container)
        └───────────┘

        + Docker Network
        + 2 Volumes (DB + WP)
```

---

## 🔐 6. Extra Important Rules from Subject

You will need to respect:

❌ Forbidden
No Docker Hub images (except base OS)
No latest tag
No --link
No network: host
No infinite loops (while true, sleep infinity)
✅ Mandatory
Dockerfiles (you build images yourself)
docker-compose.yml
.env file for variables
TLS (HTTPS only via NGINX)
Restart policy for containers
🧠 Mental Model (VERY IMPORTANT)

If you remember only ONE thing:
Image → builds → Container → uses → Volume + Network


---

PENDING

- DOCKER-COMPOSE FILE : tips, tabulation, etc