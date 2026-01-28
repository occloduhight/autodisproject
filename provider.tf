provider "aws" {
    region = "us-east-1"
    # profile = "default"
}

terraform {
 backend "s3" {
   bucket = "autodiscbucket2"
   key = "infra/terraform.tfstate"
   region = "us-east-1"
  #  profile = "default"
   encrypt = true
  #  use_lockfile = true
 } 
}

provider "vault" {
   token = var.vault_token
   address = "https://vault.odochidevops.space"
 }

#  data "vault_generic_secret" "database" {
#    path = "secret/database"
#  }
