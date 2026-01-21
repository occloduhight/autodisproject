provider "aws" {
  region = "eu-west-3"
}


terraform {
  backend "s3" {
    bucket  = "autodiscbucket"
    key     = "vault-jenkins/terraform.tfstate"
    region  = "eu-west-3"
    # profile = "default"
    encrypt = true
    # use_lockfile = true
  }
}
