provider "aws" {
  region  = var.aws_region
#  access_key = ""
#  secret_key = ""
  profile = "arn:aws:iam::var.account_id:instance_profile/var.instance_profile"
}
