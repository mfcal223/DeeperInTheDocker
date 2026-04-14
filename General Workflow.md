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
processirs: 2 CPU
Disk size: 20 GB

3. Go to Settings > Network and change NAT to Bridged Adapter. You will need to to setup an SSH connection.

4. Once in the VM, check sudo is installed:  
* apt install sudo (if not installed). Insert the same password you choose when installing the VM when asked.
* in a terminal, add your user to sudo: `usermod -aG sudo <your_user>`
    * this way you can execute admin commands without being in "sudo"
    * check: `sudo whoami` (shoudl reply "root")


### B. Set up OpenSSH to comunicate your PC and your VM

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

Find out, the VM's ip
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
Download the Dockers public signing key, and convert it into a format usable by APT and save it.

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
~$ docker --version
```
![docker version]()
* check Docker's info 
```bash 
~$ docker info
```

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


---

## 🪜 STEP 1 — Project structure

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