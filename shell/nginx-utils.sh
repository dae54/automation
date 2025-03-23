#!/bin/bash

# Function to check Nginx status
check_nginx_status() {
  echo "Checking Nginx status..."
  sudo systemctl status nginx --no-pager
}

# Function to start Nginx
start_nginx() {
  echo "Starting Nginx..."
  sudo systemctl start nginx
  echo "Nginx started successfully!"
}

# Function to stop Nginx
stop_nginx() {
  echo "Stopping Nginx..."
  sudo systemctl stop nginx
  echo "Nginx stopped successfully!"
}

# Function to restart Nginx
restart_nginx() {
  echo "Restarting Nginx..."
  sudo systemctl restart nginx
  echo "Nginx restarted successfully!"
}

# Function to reload Nginx (reloads config without downtime)
reload_nginx() {
  echo "Reloading Nginx configuration..."
  sudo systemctl reload nginx
  echo "Nginx reloaded successfully!"
}

# Function to enable Nginx (start at boot)
enable_nginx() {
  echo "Enabling Nginx to start at boot..."
  sudo systemctl enable nginx
  echo "Nginx will now start automatically on system boot."
}

# Function to disable Nginx (prevent start at boot)
disable_nginx() {
  echo "Disabling Nginx from starting at boot..."
  sudo systemctl disable nginx
  echo "Nginx is disabled from starting on boot."
}

# Function to display menu and get user input
show_menu() {
  echo "Nginx Manager - Choose an option:"
  echo "1) Check Nginx Status"
  echo "2) Start Nginx"
  echo "3) Stop Nginx"
  echo "4) Restart Nginx"
  echo "5) Reload Nginx Configuration"
  echo "6) Enable Nginx on Boot"
  echo "7) Disable Nginx on Boot"
  echo "q/Q) Exit"

  read -p "Enter your choice (1-5): " choice

  case $choice in
  1) check_nginx_status ;;
  2) start_nginx ;;
  3) stop_nginx ;;
  4) restart_nginx ;;
  5) reload_nginx ;;
  6) enable_nginx ;;
  7) disable_nginx ;;
  q|Q) echo "Exiting..."; exit 0 ;;
  *) echo "Invalid choice. Please select a number between 1 and 7 or q/Q to exit." ;;
  esac

}


# Run the main menu
while true; do
  show_menu
done
