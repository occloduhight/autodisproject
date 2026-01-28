locals {
  name = "petclinicapp"
}

# --- ACM Certificate ---
data "aws_acm_certificate" "jenkins" {
  domain       = "*.odochidevops.space"
  statuses     = ["ISSUED"]
  most_recent  = true
}

# --- VPC Module ---
module "vpc" {
  source = "./module/vpc"
  name   = local.name
}

# --- Bastion Module ---
module "bastion" {
  source      = "./module/bastion"
  name        = local.name
  key_name    = module.vpc.keypair_name
  subnets     = module.vpc.public_subnet_ids
  private_key = module.vpc.private_key
  vpc_id      = module.vpc.vpc_id
  nr_key      = var.nr_key
  nr_acc_id   = var.nr_acc_id
}

# --- Nexus Module ---
module "nexus" {
  source        = "./module/nexus"   
  name          = local.name
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]
  subnet_ids  = module.vpc.public_subnet_ids
  key_name    = module.vpc.keypair_name
  domain_name = var.domain_name
  nr_key      = var.nr_key
  nr_acc_id   = var.nr_acc_id
  acm_cert_arn = var.certificate_arn
  # acm_certificate_arn = data.aws_acm_certificate.jenkins.arn
}

# --- Ansible Module ---
module "ansible" {
  source         = "./module/ansible"
  name           = local.name
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids
  key_name       = module.vpc.keypair_name
  private_key    = module.vpc.private_key
  nr_key         = var.nr_key
  nr_acc_id      = var.nr_acc_id
  s3_bucket_name = var.s3_bucket_name
  nexus_ip       = module.nexus.nexus_ip
}

# --- Prod ASG Module ---
module "prod_asg" {
  source          = "./module/prod_asg"
  name            = local.name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  key             = module.vpc.keypair_name
  bastion_sg      = module.bastion.bastion_sg
  ansible_sg      = module.ansible.ansible_sg
  nr_key          = var.nr_key
  nr_acc_id       = var.nr_acc_id
   certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
}

# --- Stage ASG Module ---
module "stage_asg" {
  source          = "./module/stage_asg"
  name            = local.name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  key_name        = module.vpc.keypair_name
  bastion_sg      = module.bastion.bastion_sg
  ansible_sg      = module.ansible.ansible_sg
  nexus_ip        = module.nexus.nexus_ip
  nr_key          = var.nr_key
  nr_acc_id       = var.nr_acc_id
  certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
}

# --- Sonar Module ---
module "sonar" {
  source         = "./module/sonar"
  name           = local.name
  vpc_id         = module.vpc.vpc_id
  key_name       = module.vpc.keypair_name
  subnet_id      = module.vpc.public_subnet_ids[0]
  public_subnets = module.vpc.public_subnet_ids
  nr_key         = var.nr_key
  nr_acc_id      = var.nr_acc_id
  domain_name    = var.domain_name
}

# --- Database Module ---
module "database" {
  source      = "./module/database"
  name        = local.name
  vpc_id      = module.vpc.vpc_id
  db_subnets  = module.vpc.private_subnet_ids
  stage_sg    = module.stage_asg.stage_sg
  prod_sg     = module.prod_asg.prod_sg
  db_username = var.db_username
  db_password = var.db_password
}
