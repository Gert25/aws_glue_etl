provider "aws" {
  region  = var.region 
  version = "3.50.0"

  profile = var.profile
}
