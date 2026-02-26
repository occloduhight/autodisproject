#!/bin/bash
set -e

# -----------------------------
# Update system
# -----------------------------
sudo yum update -y
sudo yum upgrade -y

# -----------------------------
# Install Docker
# -----------------------------
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# -----------------------------
# Set hostname
# -----------------------------
sudo hostnamectl set-hostname stage-asg

# -----------------------------
# Install New Relic CLI and Agent
# -----------------------------
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

# Configure New Relic profile non-interactively using environment variables
export NEW_RELIC_API_KEY="${newrelic_api_key}"
export NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}"
export NEW_RELIC_REGION="EU"
export NEW_RELIC_PROFILE="stage"

sudo /usr/local/bin/newrelic install -y

# -----------------------------
# Run the Petclinic Docker container
# -----------------------------
# Stop and remove old container if it exists
docker stop appContainer || true
docker rm appContainer || true

# Pull the latest Docker image
docker pull nexus.odochidevops.space/nexus-docker-repo/apppetclinic:latest

# Run container with correct stage DB endpoint
docker run -d \
  --name appContainer \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://petclinicapp-db-instance.c184icugqfwq.eu-west-3.rds.amazonaws.com:3306/myproject" \
  -e SPRING_DATASOURCE_USERNAME="admin" \
  -e SPRING_DATASOURCE_PASSWORD="${db_password}" \
  -e SPRING_DATASOURCE_DRIVER_CLASS_NAME="com.mysql.cj.jdbc.Driver" \
  nexus.odochidevops.space/nexus-docker-repo/apppetclinic:latest



#!/bin/bash
# sudo yum update -y
# sudo yum upgrade -y
# sudo yum install -y yum-utils
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce -y
# sudo systemctl start docker
# sudo systemctl enable docker
# sudo usermod -aG docker ec2-user
# sudo hostnamectl set-hostname stage-asg
# curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY="${newrelic_api_key}" NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -yc:\Users\chinw\Desktop\autodisproject\module\prod_asg