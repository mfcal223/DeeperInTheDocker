# Connect (VM running) from host
```bash
ssh <your_VM_username>@<VM_ip>
#example
ssh mcalciat@10.13.200.243
```
(use `ip a` in the VM to verify the ip)


first time -> confirm **yes** and use VM's password for that username.


# 📦 Copy files 

## 📤 Copy file FROM your local machine → VM
```bash
scp file.txt username@VM_IP:/home/username/
```
Example:
```
scp test.txt maria@192.168.1.45:/home/maria/
```

## 📥 Copy file FROM VM → your local machine
```bash
scp username@VM_IP:/home/username/file.txt .
```
Example:
```
scp maria@192.168.1.45:/home/maria/test.txt .
```

## 📤📥Copy folders FROM your local machine → VM
```bash
scp -r folder/ username@VM_IP:/home/username/

```
# 🔥 Generate SSH-keygen
Avoid typing password every time (SSH keys).  
On your local machine:
```bash
ssh-keygen
ssh-copy-id username@VM_IP
```

# 🧱 Connection fails (VERY common)
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