#!/bin/bash
set -e  # exit on first error

# Update and upgrade system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker APT repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to Docker group
sudo usermod -aG docker ubuntu

# Set hostname
sudo hostnamectl set-hostname prod-asg

# Install New Relic CLI
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

# Run New Relic installation
sudo NEW_RELIC_API_KEY="${newrelic_api_key}" \
     NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" \
     NEW_RELIC_REGION=EU \
     /usr/local/bin/newrelic install -y

# Verify Docker installation
docker --version