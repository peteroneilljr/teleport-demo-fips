terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.73"
    }
  }
}
provider "aws" {
  region = var.aws_gov_region

  access_key = var.aws_gov_access_key
  secret_key = var.aws_gov_secret_key
  token      = var.aws_gov_session_token

  default_tags {
    tags = var.aws_gov_tags
  }
}
data "aws_caller_identity" "current" {}

provider "aws" {
  alias = "dns"
  region = var.aws_dns_region

  access_key = var.aws_dns_access_key
  secret_key = var.aws_dns_secret_key
  token      = var.aws_dns_session_token

  default_tags {
    tags = var.aws_dns_tags
  }
}
