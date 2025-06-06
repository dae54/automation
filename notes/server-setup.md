# FIRST TIME SETUP - UBUNTU VPS

- Disabling root login 
- enabling SSH access with key authentication (no passwords) 

## Create a New User
✅ 1. SSH into Your Server as Root (or a user with sudo)
```bash
ssh root@your-server-ip
adduser yourusername
# Follow the prompts to set a password and optional user details.
usermod -aG sudo yourusername
# This gives the user permission to use sudo.
```

## ✅ 2. Set Up SSH Key Authentication for the New User
🔑 On your local machine (if you don’t already have a key):`
```bash
ssh-keygen -t ed25519 -C "add comment"

# This will generate:
# ~/.ssh/id_ed25519 (private key)
# ~/.ssh/id_ed25519.pub (public key)
```

📤 Copy the Public Key to the Server
Use ssh-copy-id (recommended):

```bash
ssh-copy-id yourusername@your-server-ip
```


## ✅ 3. Disable SSH Password Authentication
Edit the SSH config:

```bash
sudo nano /etc/ssh/sshd_config

# Find and set:
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes

# Then save and exit.

# Restart SSH
sudo systemctl restart ssh

```


## Test Your SSH Login Before Logging Out
In a new terminal, test:

```bash
ssh yourusername@your-server-ip
```