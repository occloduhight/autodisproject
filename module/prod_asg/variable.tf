variable "name" {}
variable "key_name" {}
variable "private_subnets" {}
variable "vpc_id" {}
variable "ansible_sg" {}
variable "bastion_sg" {}
variable "public_subnets" {}

variable "newrelic_api_key" {}
variable "newrelic_account_id" {} 


variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate"
  default     = "arn:aws:acm:us-east-1:015937138823:certificate/c78b52ad-829c-4621-a251-979a4f914984"
  
}


variable "domain_name" {
  description = "Domain name for Route 53"
  type        = string
}
