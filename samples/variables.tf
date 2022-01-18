variable "profile" {
    type = string
    description = "the name AWS profile to use to deploy infrastructure"
   default = "default"
}


variable "region" {
  type = string 
  description = "AWS region to deploy AWS infrastructure"
  default = "eu-west-1"
}

