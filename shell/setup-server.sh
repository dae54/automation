#!/bin/bash

# Function to update system packages
update_system() {
    echo "Updating system packages..."
    sudo apt update
}

# Function to install Nginx
install_nginx() {
  update_system

  echo "Installing Nginx..."
  sudo apt install -y nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
  echo "Nginx installed successfully!"
}

# Function to install NVM and Node.js (LTS)
install_nvm_node() {
  update_system

  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

  # Load NVM immediately
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  echo "Installing Node.js (latest LTS)..."
  nvm install --lts
  nvm use --lts

  # Verify installation
  echo "Node.js version: $(node -v)"
  echo "npm version: $(npm -v)"
}

# Function to install Certbot (Let's Encrypt)
install_certbot() {
  update_system
  
  echo "Installing Certbot..."
  sudo apt install -y certbot python3-certbot-nginx
  echo "Certbot installed successfully!"

  # Verify installation
  echo "Nginx version: $(nginx -v 2>&1)"
  echo "Certbot version: $(certbot --version)"
}

# Function to display menu and get user input
show_menu() {
  echo "Choose an option:"
  echo "1) Update System Packages"
  echo "2) Install Nginx"
  echo "3) Install NVM & Node.js"
  echo "4) Install Certbot (Let's Encrypt)"
  echo "5) Run All"
  echo "6) Exit"
    
  read -p "Enter your choice (1-6): " choice

  case $choice in
      1) update_system ;;
      2) install_nginx ;;
      3) install_nvm_node ;;
      4) install_certbot ;;
      5) 
          install_nginx
          install_nvm_node
          install_certbot
          echo "All tasks completed!"
          ;;
      6) echo "Exiting..."; exit 0 ;;
      *) echo "Invalid choice. Please enter a number between 1-6." ;;
  esac
}

# Run the main menu
while true; do
  show_menu
done
