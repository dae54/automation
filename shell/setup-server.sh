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

setup_ufw() {
  echo "✅ Starting Safe UFW Setup..."

  # Allow SSH first (port 22) to avoid locking yourself out
  sudo ufw allow 22/tcp
  echo "✅ Allowed SSH on port 22."

  # Allow web server ports
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  echo "✅ Allowed HTTP (80) and HTTPS (443)."

  # Set default policies: deny all incoming, allow all outgoing
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  echo "✅ Set default policies (deny incoming, allow outgoing)."

  # Enable UFW (only after setting rules)
  sudo ufw enable
  echo "✅ UFW firewall is now active and safe!"

  # Show the current UFW rules
  sudo ufw status verbose
}

setup_fail2ban() {
  sudo apt-get install fail2ban
  echo "✅ Installed Fail2Ban."

  # Start Fail2Ban and ensure it starts at boot
  sudo systemctl start fail2ban
  sudo systemctl enable fail2ban
  echo "✅ Started and enabled Fail2Ban."
}

# Function to install NVM and Node.js (LTS)
install_nvm_node() {
  update_system

  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

  # Load NVM immediately
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  echo "Installing Node.js v20.18.1"
  nvm install 20.18.1
  nvm use 20.18.1

  # Verify installation
  echo "Node.js version: $(node -v)"
  echo "npm version: $(npm -v)"
}

# Function to display menu and get user input
show_menu() {
  echo "Choose an option:"
  echo "1) Update System Packages"
  echo "2) Install Nginx"
  echo "3) Install NVM & Node.js"
  echo "4) Setup & enable ufw"
  echo "5) Setup fail2ban"
  echo "6) Run All"
  echo "q/Q) Exit"

  read -p "Enter your choice (1-6): " choice

  case $choice in
  1) update_system ;;
  2) install_nginx ;;
  3) install_nvm_node ;;
  4) setup_ufw ;;
  5) setup_fail2ban ;;
  6)
    install_nginx
    install_nvm_node
    setup_ufw
    setup_fail2ban
    echo "All tasks completed!"
    ;;
  q | Q)
    echo "Exiting..."
    exit 0
    ;;
  *) echo "Invalid choice. Please enter a number between 1-6 or q/Q to exit." ;;
  esac
}

# Run the main menu
while true; do
  show_menu
done
