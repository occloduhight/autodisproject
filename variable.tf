
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Ansible scripts"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
  default     = "arn:aws:acm:us-east-1:015937138823:certificate/c78b52ad-829c-4621-a251-979a4f914984"
}

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
variable "newrelic_api_key" {}
variable "newrelic_account_id" {}

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