#!/bin/bash
# set -e

# Update system
sudo yum update -y
sudo yum upgrade -y

# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Set hostname
sudo hostnamectl set-hostname stage-asg

# Install New Relic CLI and Infrastructure Agent
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash

sudo NEW_RELIC_API_KEY="${newrelic_api_key}" \
NEW_RELIC_ACCOUNT_ID="${newrelic_account_id}" \
NEW_RELIC_REGION=EU \
/usr/local/bin/newrelic install -y

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
# curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY="${nr_key}" NEW_RELIC_ACCOUNT_ID="${nr_acc_id}" NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -yc:\Users\chinw\Desktop\autodisproject\module\prod_asg