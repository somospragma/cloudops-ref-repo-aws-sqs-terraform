###########################################
############# AWS Provider ################
###########################################

provider "aws" {
  alias   = "principal"                                            # Write alias manually
  region  = var.aws_region
  profile = var.profile                                          # Write profile manually (on demand)

  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_NUMBER:role/ROLE_NAME"      # Write account number and role name manually (on demand)
  # }
  
  default_tags {
    tags = var.common_tags
  }
}

###########################################
# Version definition - Terraform - Providers
###########################################

terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
  }
}
