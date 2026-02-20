variable "name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "subnet_ids" {}
variable "key_name" {}
variable "domain_name" {}
variable "newrelic_api_key" {}
variable "newrelic_account_id" {}
#  variable "acm_certificate_arn" {}
#  variable "jenkins_sg_id" {}
variable "acm_cert_arn" {
  type        = string
  description = "ARN of the ACM certificate for ELB HTTPS"
}

  