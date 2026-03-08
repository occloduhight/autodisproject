#!/bin/bash

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install prerequisite packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
sudo apt install -y docker.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Set hostname
sudo hostnamectl set-hostname stage-asg

# Install New Relic
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && \
sudo NEW_RELIC_API_KEY="${newrelic_api_key}" \
NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" \
NEW_RELIC_REGION=EU \
/usr/local/bin/newrelic install -y