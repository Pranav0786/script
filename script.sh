#!/bin/bash

# Function to check the Linux distribution
get_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "Unknown"
  fi
}

# Function to install Docker and Docker Compose
install_docker() {
  echo "Installing Docker..."
  if command -v docker &>/dev/null; then
    echo "Docker is already installed."
  else
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    echo "Docker installed successfully."
  fi

  # Install Docker Compose v2
  echo "Installing Docker Compose..."
  apt-get install -y docker-compose-plugin
  echo "Docker Compose installation completed."

  systemctl enable --now docker
  usermod -aG docker "$SUDO_USER"
  echo "Docker installation completed. Please restart your shell for user group changes to take effect."
}

# Function to install Minikube
install_minikube() {
  echo "Installing Minikube..."
  if ! command -v minikube &>/dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install -m 755 minikube-linux-amd64 /usr/local/bin/minikube
    rm -f minikube-linux-amd64
    echo "Minikube installation completed."
  else
    echo "Minikube is already installed."
  fi
}

# Function to install kubectl
install_kubectl() {
  echo "Installing kubectl..."
  if ! command -v kubectl &>/dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -m 755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
    echo "kubectl installation completed."
  else
    echo "kubectl is already installed."
  fi
}

# Function to install VS Code
install_vscode() {
  echo "Installing Visual Studio Code..."
  if ! command -v code &>/dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
    apt-get update
    apt-get install -y code
    echo "VS Code installation completed."
  else
    echo "VS Code is already installed."
  fi
}

# Function to set Cloudinary image as wallpaper (only for GNOME)
set_wallpaper() {
  WALLPAPER_URL="https://res.cloudinary.com/dfuwno067/image/upload/v1739529086/META_Wallpaper_yrwn0j.png"
  USER_HOME=$(eval echo ~$SUDO_USER)
  WALLPAPER_PATH="$USER_HOME/Desktop/wallpaper.jpg"

  sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/Desktop"
  sudo -u "$SUDO_USER" wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL"

  echo "Wallpaper downloaded to $WALLPAPER_PATH"
}

# Function to check versions of installed tools
check_versions() {
  echo "Checking installed versions..."
  docker --version || echo "Docker not found"
  docker compose version || echo "Docker Compose not found"
  minikube version || echo "Minikube not found"
  kubectl version --client || echo "kubectl not found"
  code --version || echo "VS Code not found"
}

# Main script execution
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

install_docker
install_minikube
install_kubectl
install_vscode
set_wallpaper
check_versions

echo "All tasks completed successfully!"
