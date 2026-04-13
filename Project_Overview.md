# Project overview

###  Core Requirements
- The entire project must run inside a virtual machine.  
- All configuration files must be inside a `srcs/ folder`.  
- A `Makefile` must build and start everything via `docker-compose`.  
- You must create your own Docker images using `Dockerfiles` (❌ no pulling ready-made images except base OS like Debian/Alpine).  

### Required Services
You must implement:

1. Web Server
- Container with NGINX
- Must support only:
    - TLSv1.2 or TLSv1.3
    - This is the only entry point (port 443)
2. Application
- Container with: 
    - WordPress
    - php-fpm 
    - ❌ No nginx inside this container
3. Database
- Container with: MariaDB
   - ❌ No nginx

###  Storage (VERY IMPORTANT)
- You must create 2 persistent volumes:
    1. WordPress database
    2. WordPress website files
- Rules:
    1. Must be named volumes (❌ no bind mounts)
    2. Stored on host at: `/home/<login>/data`

###  Networking
Containers must communicate via a `Docker network`.  
❌ Forbidden:
```
--link
network: host
```
###  Other Important Rules
- Each service = 1 container
- Containers must:
    - restart automatically
- ❌ Forbidden:
    - infinite loops (while true, sleep infinity, tail -f)
- Use:
    - `.env` file for variables
    - `Docker secrets` for passwords

###  WordPress Requirements
Must contain:  
1 admin user (but NOT named "admin")  
1 normal user  

### Domain Setup
You must configure:
```
<login>.42.fr → local IP
```

### Documentation Required

You must include:
* `README.md` → explanation + concepts  
* `USER_DOC.md` → how to use the system  
* `DEV_DOC.md` → how to build and maintain it

###  Bonus (optional)

Examples:
```
Redis cache
FTP server
Static website
Adminer
Any extra service (must justify)
```
