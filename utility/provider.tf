provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket = "autodiscbucket2"
    key    = "vault-jenkins/terraform.tfstate"
    region = "us-east-1"
    #  profile = "default"
    encrypt = true
    #  use_lockfile = true
  }
}
