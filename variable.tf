# variable "nr_key" {}
# variable "nr_acc_id" {}
# variable "domain_name" {
#   description = "The domain name for SSL certificate or service endpoint"
#   type        = string
# }
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Ansible scripts"
  type        = string
}

# # variable "certificate_arn" {
# #   description = "Wildcard ACM certificate ARN for *.odochidevops.space"
# #   default     = "arn:aws:acm:us-east-1:015937138823:certificate/6fd8d6eb-dd5f-493f-89c9-ac911fdf063a"
# # }
variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
  default     = "arn:aws:acm:us-east-1:015937138823:certificate/6fd8d6eb-dd5f-493f-89c9-ac911fdf063a"
}

# variable "db_username" {}
# variable "db_password" {}

# variable "vault_token" {}
# variable "region" {}


# Database username
variable "db_username" {
  type        = string
  description = "The username for the database"
}

# Database password
variable "db_password" {
  type        = string
  description = "The password for the database"
  sensitive   = true
}

# New Relic API key
variable "nr_key" {
  type        = string
  description = "New Relic API key"
  sensitive   = true
}

# New Relic Account ID
variable "nr_acc_id" {
  type        = string
  description = "New Relic Account ID"
}

# Vault token
variable "vault_token" {
  type        = string
  description = "Vault authentication token"
  sensitive   = true
}

# Domain name
variable "domain_name" {
  type        = string
  description = "Domain name for the project"
}