# DeeperInTheDocker
This project focuses on building a small infrastructure using Docker containers, all running inside a virtual machine.  The objective is to create multiple isolated services that work together, each inside its own container, and orchestrate them using Docker Compose.

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