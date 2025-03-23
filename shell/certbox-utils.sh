#!/bin/bash

# Function to check Nginx status
remove_certbox_package() {
  echo "Checking Nginx status..."
  sudo apt-get remove certbot
}


# Function to install Snapd
install_snapd() {
  echo "Installing Snapd..."
  sudo apt update
  sudo apt install -y snapd
  echo "Snapd installed successfully!"
}


# Function to install Certbot using Snap
install_certbot() {
  remove_certbox_package
  
  echo "Installing Certbot using Snap..."
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  echo "Certbot installed successfully!"
}


# Function to test Certbot auto-renewal
test_certbot_renewal() {
  echo "Testing Certbot auto-renewal..."
  sudo certbot renew --dry-run
  echo "Certbot auto-renewal test completed!"
}


# Function to obtain SSL certificate for Nginx
obtain_ssl_certificate() {
  read -p "Enter your domain name (e.g., example.com): " domain
  read -p "Enter your email address for certificate registration: " email
  echo "Obtaining SSL certificate for $domain..."
  sudo certbot --nginx -d "$domain" --non-interactive --agree-tos -m "$email"
  echo "SSL certificate obtained and configured for Nginx!"
}


# Function to obtain wildcard SSL certificate for Nginx
obtain_wildcard_ssl_certificate() {
  if [ -z "$1" ]; then
    echo "Usage: obtain_ssl_certificate <wildcard_domain>"
    echo "Example: obtain_ssl_certificate '*.example.com'"
    return 1
  fi

  wildcard_domain="$1"
  
  read -p "Enter your email address for certificate registration: " email
  echo "Obtaining wildcard SSL certificate for $wildcard_domain..."
  
  # Certbot command to obtain the wildcard SSL certificate
  sudo certbot certonly --manual --preferred-challenges=dns -d "$wildcard_domain" -m "$email" --agree-tos --non-interactive

  echo "Wildcard SSL certificate obtained for $wildcard_domain!"
}


# Function to display menu and get user input
show_menu() {
  echo "Certbot & Nginx Setup - Choose an option:"
  echo "1) Install Snapd"
  echo "2) Install Certbot using Snap"
  echo "3) Obtain SSL Certificate for Nginx"
  echo "4) Obtain Wildcard SSL Certificate"
  echo "5) Test Certbot Auto-Renewal"
  echo "6) Exit"
    
  read -p "Enter your choice (1-5): " choice

  case $choice in
    1) install_snapd ;;
    2) install_certbot ;;
    3) obtain_ssl_certificate ;;
    4) 
      read -p "Enter your wildcard domain (e.g., '*.example.com'): " wildcard_domain
      obtain_wildcard_ssl_certificate "$wildcard_domain"
      ;;
    5) test_certbot_renewal ;;
    6) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice. Please enter a number between 1-5." ;;
  esac
}

# Run the main menu loop
while true; do
    show_menu
done