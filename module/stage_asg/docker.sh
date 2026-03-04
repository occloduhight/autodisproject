#!/bin/bash
set -e  # exit on first error

sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo hostnamectl set-hostname stage-asg
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash
sudo NEW_RELIC_API_KEY="${newrelic_api_key}" NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y
docker --version