#!/bin/bash

### -----------------------------
### Docker Installation Functions
### -----------------------------

uninstall_conflicting_package() {
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg
  done
}

add_docker_gpg_key() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
}

add_repository_to_apt_source() {
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
}

install_docker() {
  echo "Installing Docker Engine..."
  uninstall_conflicting_package
  add_docker_gpg_key
  add_repository_to_apt_source
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

### ----------------------------
### Docker Utility Functions
### ----------------------------

check_docker_status() {
  systemctl is-active --quiet docker && echo "Docker is running." || echo "Docker is NOT running."
}

start_docker() {
  sudo systemctl start docker && echo "Docker started."
}

stop_docker() {
  sudo systemctl stop docker && echo "Docker stopped."
}

restart_docker() {
  sudo systemctl restart docker && echo "Docker restarted."
}

enable_docker() {
  sudo systemctl enable docker && echo "Docker enabled on boot."
}

disable_docker() {
  sudo systemctl disable docker && echo "Docker disabled on boot."
}

check_docker_installed() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing..."
    install_docker
  else
    echo "Docker is already installed."
  fi
}

### ----------------------------
### Interactive Menu
### ----------------------------

show_menu() {
  echo
  echo "Docker Manager - Choose an option:"
  echo "1) Check Docker Status"
  echo "2) Start Docker"
  echo "3) Stop Docker"
  echo "4) Restart Docker"
  echo "5) Enable Docker on Boot"
  echo "6) Disable Docker on Boot"
  echo "7) Install Docker (if not installed)"
  echo "q/Q) Exit"
  echo

  read -p "Enter your choice (1-7 or q): " choice

  case $choice in
    1) check_docker_status ;;
    2) start_docker ;;
    3) stop_docker ;;
    4) restart_docker ;;
    5) enable_docker ;;
    6) disable_docker ;;
    7) check_docker_installed ;;
    q|Q) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

### ----------------------------
### Main Program Loop
### ----------------------------

while true; do
  show_menu
done
