#!/bin/bash
set -e

# Log everything
exec > /var/log/user-data.log 2>&1

echo "Starting instance setup..."

# Wait for network
sleep 15

# Update packages
sudo apt-get update -y

# Install dependencies
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repo
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker

# Wait for Docker
sleep 10

# Verify Docker
sudo systemctl status docker
docker --version

# Add user to docker group
sudo usermod -aG docker ubuntu

# Set hostname
sudo hostnamectl set-hostname stage-asg

# Install New Relic
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

sudo NEW_RELIC_API_KEY="${newrelic_api_key}" \
NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" \
NEW_RELIC_REGION=EU \
/usr/local/bin/newrelic install -y

echo "Setup completed"