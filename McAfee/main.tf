module "test-module" {
  source = "../modules/local-module"
  account_id = var.account_id
  profile_name = var.profile_name
  aws_region = var.aws_region
  vpc_id = var.vpc_id
}
