#!/bin/bash

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Install NVM (Node Version Manager)
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Load NVM immediately (without requiring a new shell session)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the latest LTS version of Node.js
echo "Installing Node.js (latest LTS)..."
nvm install --lts
nvm use --lts

# Verify installation
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Install Certbot (Let's Encrypt) and Nginx plugin
echo "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Verify installation
echo "Nginx version: $(nginx -v 2>&1)"
echo "Certbot version: $(certbot --version)"

echo "Installation complete!"
