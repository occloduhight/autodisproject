#!/bin/bash
set -e

# Log everything
exec > /var/log/user-data.log 2>&1

echo "Starting RHEL 9 instance setup..."

# Wait for network
sleep 15

# Update packages
sudo dnf update -y
sudo dnf upgrade -y

# Install dependencies
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 curl gnupg2

# Add Docker CE repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker packages
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker

# Wait for Docker to initialize
sleep 10

# Verify Docker installation
sudo systemctl status docker
docker --version

# Add ec2-user to Docker group
sudo usermod -aG docker ec2-user

# Set hostname
sudo hostnamectl set-hostname stage-asg

# Install New Relic CLI
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

# Configure New Relic
export NEW_RELIC_API_KEY="${newrelic_api_key}"
export NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}"
export NEW_RELIC_REGION=EU
sudo /usr/local/bin/newrelic install -y