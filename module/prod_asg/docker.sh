#!/bin/bash
# set -e

# Update and upgrade system packages
sudo yum update -y
sudo yum upgrade -y

# Install prerequisites
sudo yum install -y yum-utils curl ca-certificates

# Add Docker repository (RHEL/CentOS compatible)
sudo yum-config-manager --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to Docker group
sudo usermod -aG docker ec2-user

# Set hostname
sudo hostnamectl set-hostname prod-asg

# Install New Relic CLI
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

# Run New Relic installation
sudo NEW_RELIC_API_KEY="${newrelic_api_key}" \
NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" \
NEW_RELIC_REGION=EU \
/usr/local/bin/newrelic install -y