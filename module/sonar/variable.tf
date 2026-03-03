variable "name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "domain_name" {}
variable "public_subnets" {}
variable "newrelic_api_key" {}
variable "newrelic_account_id" {}
# variable "nr_key" {}
# variable "nr_acc_id" {}
variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate"
  default     = "arn:aws:acm:us-east-1:015937138823:certificate/c78b52ad-829c-4621-a251-979a4f914984"
}
