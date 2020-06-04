provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::591514548448:role/OrganizationAccountAccessRole"
  }
}

module "this" {
  source             = "../../.."
  name               = "vpc"
  namespace          = "avst-tf"
  stage              = "integration"
  availability_zones = ["us-east-1a", "us-east-1b"]
  cidr_block         = "10.0.0.0/16"
}
