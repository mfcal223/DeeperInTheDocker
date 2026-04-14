to connect (VM running)
from host
```
ssh mcalciat@10.13.200.243
```
(use ip a in the VM to verify the ip)


first time -> confirm yes and use password of VM


📦 5. Copy files (MOST IMPORTANT PART)
➤ Copy file FROM your local machine → VM
scp file.txt username@VM_IP:/home/username/

Example:

scp test.txt maria@192.168.1.45:/home/maria/
➤ Copy file FROM VM → your local machine
scp username@VM_IP:/home/username/file.txt .

Example:

scp maria@192.168.1.45:/home/maria/test.txt .
➤ Copy folders (recursive)
scp -r folder/ username@VM_IP:/home/username/
⚡ 6. Pro Tip (VERY USEFUL)
Avoid typing password every time (SSH keys)

On your local machine:

ssh-keygen

Then:

ssh-copy-id username@VM_IP

👉 After this:

No more password needed 🔥


🧱 7. If connection fails (VERY common)

Check these:

🔹 1. VM network mode
Use Bridged Adapter (best)
OR
Use NAT + port forwarding
🔹 2. Firewall

Inside VM:

sudo ufw allow ssh
🔹 3. SSH service
sudo systemctl status ssh