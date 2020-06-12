module "this" {
  source             = "../../.."
  namespace          = "adaptavist-terraform"
  stage              = "integration"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  cidr_block         = "10.0.0.0/16"
}
